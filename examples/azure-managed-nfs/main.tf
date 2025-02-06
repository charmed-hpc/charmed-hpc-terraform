terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.14.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.17"
    }
  }
}

provider "juju" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "nfs-group" {
  name     = "nfs-group"
  location = "East US"
}

resource "azurerm_virtual_network" "nfs-vnet" {
  name                = "nfs-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.nfs-group.location
  resource_group_name = azurerm_resource_group.nfs-group.name
  subnet              = []
}

resource "azurerm_network_security_group" "nfs-nsg" {
  name                = "nfs-nsg"
  location            = azurerm_resource_group.nfs-group.location
  resource_group_name = azurerm_resource_group.nfs-group.name
  security_rule {
    name                       = "Allow-SSH-Internet"
    description                = "Open SSH inbound ports"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
    access                     = "Allow"
    priority                   = 100
    direction                  = "Inbound"
  }
}

resource "azurerm_subnet" "nfs-subnet" {
  name                                          = "nfs-subnet"
  resource_group_name                           = azurerm_resource_group.nfs-group.name
  virtual_network_name                          = azurerm_virtual_network.nfs-vnet.name
  address_prefixes                              = ["10.0.1.0/24"]
  private_endpoint_network_policies             = "Enabled"
  private_link_service_network_policies_enabled = true
}

resource "azurerm_subnet_network_security_group_association" "nfs-nsg-to-subnet" {
  subnet_id                 = azurerm_subnet.nfs-subnet.id
  network_security_group_id = azurerm_network_security_group.nfs-nsg.id
}

resource "juju_model" "charmed-hpc" {
  name = "charmed-hpc"

  cloud {
    name   = "azure"
    region = "eastus"
  }

  config = {
    resource-group-name = azurerm_resource_group.nfs-group.name
    network             = azurerm_virtual_network.nfs-vnet.name
  }
}

module "nfs-share" {
  source = "git::https://github.com/charmed-hpc/charmed-hpc-terraform//modules/azure-managed-nfs"

  name                = "nfs-share"
  resource_group_name = azurerm_resource_group.nfs-group.name
  subnet_info = {
    name                 = azurerm_subnet.nfs-subnet.name
    virtual_network_name = azurerm_subnet.nfs-subnet.virtual_network_name
  }
  model_name = juju_model.charmed-hpc.name
  quota      = 100
  mountpoint = "/nfs/home"
  depends_on = [
    azurerm_resource_group.nfs-group
  ]
}

resource "juju_application" "ubuntu" {
  name  = "ubuntu"
  model = juju_model.charmed-hpc.name

  charm {
    name = "ubuntu"
    base = "ubuntu@24.04"
  }

  units = 1
}

# Since the filesystem client is a subordinate charm, it uses
# the `juju-info` endpoint to integrate with other charms.
resource "juju_integration" "ubuntu-to-filesystem-client" {
  model = juju_model.charmed-hpc.name

  application {
    name     = juju_application.ubuntu.name
    endpoint = "juju-info"
  }

  application {
    name     = module.nfs-share.app_name
    endpoint = "juju-info"
  }
}
