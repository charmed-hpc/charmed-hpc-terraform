data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  name = var.subnet_info.name
  virtual_network_name = var.subnet_info.virtual_network_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_managed_lustre_file_system" "az-lustre" {
  name                   = var.name
  resource_group_name    = data.azurerm_resource_group.rg.name
  location               = data.azurerm_resource_group.rg.location
  subnet_id              = data.azurerm_subnet.subnet.id
  sku_name               = var.sku_name
  storage_capacity_in_tb = var.storage_capacity_in_tb
  zones                  = var.zones

  maintenance_window {
    day_of_week     = "Friday"
    time_of_day_in_utc = "22:00"
  }
}

module "lustre-server-proxy" {
  source = "git::https://github.com/charmed-hpc/filesystem-charms//charms/lustre-server-proxy/terraform"

  app_name   = var.name
  model_name = var.model_name
  channel    = var.lustre_server_proxy_channel
  config     = {
    "mgs-nids": "${azurerm_managed_lustre_file_system.az-lustre.mgs_address}@tcp"
    "fs-name": "lustrefs"
  }
}

# module "filesystem-client" {
#   source = "git::https://github.com/charmed-hpc/filesystem-charms//charms/filesystem-client/terraform"
# 
#   model_name = var.model_name
#   channel    = var.filesystem_client_channel
# }
# 
# resource "juju_integration" "lustre-filesystem-to-client" {
#   model = var.model_name
# 
#   application {
#     name     = module.lustre-server-proxy.app_name
#     endpoint = module.controller.provides.filesystem
#   }
# 
#   application {
#     name     = module.filesystem-client.app_name
#     endpoint = module.filesystem-client.requires.filesystem
#   }
# }
