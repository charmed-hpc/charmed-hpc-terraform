variable "model_name" {
  description = "Name of the target Juju model."
  type        = string
}

variable "name" {
  description = "Name for the Azure Managed Lustre File System resource."
  type        = string
  default     = "lustre-filesystem"
}

variable "lustre_server_proxy_channel" {
  description = "Channel to deploy lustre-server-proxy from."
  type        = string
  default     = "latest/edge"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group where the Azure Managed Lustre File System will be allocated."
  type        = string
}

variable "subnet_info" {
  description = "Info about the subnet where the Azure Managed Lustre File System will be allocated."
  type        = object({ name=string, virtual_network_name=string })
}

variable "sku_name" {
  description = "SKU name for the Azure Managed Lustre File System."
  type        = string
}

variable "storage_capacity_in_tb" {
  description = "Size of the Azure Managed Lustre File System in TiB. The valid values for this field are dependant on which sku_name has been defined in the configuration file."
  type        = number
}

variable "zones" {
  description = "List of availability zones for the Azure Managed Lustre File System."
  type        = list(string)
}
