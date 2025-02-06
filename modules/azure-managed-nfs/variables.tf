variable "name" {
  type        = string
  default     = "nfs-share"
  description = "Name for the exported NFS share and the prefix of all the related resources."
}

variable "quota" {
  description = "The maximum size of the share, in gigabytes."
  type        = number
}

variable "mountpoint" {
  description = "Path to the directory where the NFS share will be mounted."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure resource group where the NFS share will be allocated."
  type        = string
}

variable "subnet_info" {
  description = "Information about the subnet where the NFS share will be allocated."
  type        = object({ name = string, virtual_network_name = string })
}

variable "model_name" {
  description = "Name of the target Juju model."
  type        = string
}

variable "nfs_server_proxy_channel" {
  description = "Channel to deploy the nfs-server-proxy charm from."
  type        = string
  default     = "latest/edge"
}

variable "filesystem_client_channel" {
  description = "Channel to deploy the filesystem-client charm from."
  type        = string
  default     = "latest/edge"
}
