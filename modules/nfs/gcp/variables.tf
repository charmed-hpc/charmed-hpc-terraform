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

variable "name" {
  description = "Name for the exported NFS share and the prefix of all the related resources."
  type        = string
  default     = "nfs-share"
  nullable    = false
}

variable "network" {
  description = "Name of the VPC Network where the NFS instance will be emplaced."
  type        = string
  nullable    = false
}

variable "location" {
  description = "The name of the location of the instance. This can be a region for ENTERPRISE tier instances."
  type        = string
  default     = null
}

variable "tier" {
  description = <<-EOT
  The service tier of the instance.
  Possible values include: STANDARD, PREMIUM, BASIC_HDD, BASIC_SSD, HIGH_SCALE_SSD, ZONAL, REGIONAL and ENTERPRISE
  EOT
  type        = string
  nullable    = false
}

variable "capacity_gb" {
  description = <<-EOT
  File share capacity in GiB.
  This must be at least 1024 GiB for the standard tier, or 2560 GiB for the premium tier.
  EOT
  type        = number
  nullable    = false
}

variable "mountpoint" {
  description = "Path to the directory where the NFS share will be mounted."
  type        = string
  nullable    = false
}

variable "model_name" {
  description = "Name of the target Juju model."
  type        = string
  nullable    = false
}

variable "nfs_server_proxy_channel" {
  description = "Channel to deploy the nfs-server-proxy charm from."
  type        = string
  default     = "latest/edge"
  nullable    = false
}

variable "filesystem_client_channel" {
  description = "Channel to deploy the filesystem-client charm from."
  type        = string
  default     = "latest/edge"
  nullable    = false
}
