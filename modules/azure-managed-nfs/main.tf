# Copyright 2025 Canonical Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

data "azurerm_resource_group" "nfs" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "nfs" {
  name                = var.subnet_info.virtual_network_name
  resource_group_name = data.azurerm_resource_group.nfs.name
}

data "azurerm_subnet" "nfs" {
  name                 = var.subnet_info.name
  virtual_network_name = var.subnet_info.virtual_network_name
  resource_group_name  = data.azurerm_resource_group.nfs.name
}

# Account names must be unique through all of Azure, so
# it's easier to just generate a random user.
resource "random_id" "nfs" {
  byte_length = 12
}

resource "azurerm_storage_account" "nfs" {
  name                = random_id.nfs.hex
  resource_group_name = data.azurerm_resource_group.nfs.name
  location            = data.azurerm_resource_group.nfs.location

  # Only Premium accounts can support the NFS protocol.
  account_tier             = "Premium"
  account_kind             = "FileStorage"
  account_replication_type = "LRS"

  # As of 10-02-2025, NFS on Azure doesn't support HTTPS, so we
  # need to use unencrypted HTTP.
  https_traffic_only_enabled = false
}

resource "azurerm_storage_share" "nfs" {
  name               = var.name
  storage_account_id = azurerm_storage_account.nfs.id
  quota              = var.quota
  enabled_protocol   = "NFS"
}

resource "azurerm_private_endpoint" "nfs" {
  name                = "${var.name}-endpoint"
  location            = data.azurerm_resource_group.nfs.location
  resource_group_name = data.azurerm_resource_group.nfs.name
  subnet_id           = data.azurerm_subnet.nfs.id

  private_service_connection {
    name                           = "nfs-privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.nfs.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.name}-dz-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.nfs.id]
  }
}


# The name of this resource must be an URL specific to the Azure service
# that will be related with the private endpoint.
# List of DNS zone values:
# https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns
resource "azurerm_private_dns_zone" "nfs" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = data.azurerm_resource_group.nfs.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "nfs" {
  name                  = "${var.name}-dz-vnet-link"
  resource_group_name   = data.azurerm_resource_group.nfs.name
  private_dns_zone_name = azurerm_private_dns_zone.nfs.name
  virtual_network_id    = data.azurerm_virtual_network.nfs.id
}

module "nfs-server-proxy" {
  source = "git::https://github.com/charmed-hpc/filesystem-charms//charms/nfs-server-proxy/terraform"

  app_name   = "${var.name}-server"
  model_name = var.model_name
  channel    = var.nfs_server_proxy_channel
  config = {
    "hostname" : azurerm_storage_account.nfs.primary_file_host
    "path" : "/${azurerm_storage_account.nfs.name}/${azurerm_storage_share.nfs.name}"
  }

  depends_on = [
    azurerm_private_endpoint.nfs
  ]
}

module "filesystem-client" {
  source = "git::https://github.com/charmed-hpc/filesystem-charms//charms/filesystem-client/terraform"

  app_name   = "${var.name}-client"
  model_name = var.model_name
  channel    = var.filesystem_client_channel
  config = {
    "mountpoint" : var.mountpoint
  }
}

resource "juju_integration" "nfs" {
  model = var.model_name

  application {
    name     = module.nfs-server-proxy.app_name
    endpoint = module.nfs-server-proxy.provides.filesystem
  }

  application {
    name     = module.filesystem-client.app_name
    endpoint = module.filesystem-client.requires.filesystem
  }
}
