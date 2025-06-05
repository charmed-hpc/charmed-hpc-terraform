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
  type        = string
  default     = "nfs-share"
  description = "Name for the exported NFS share and the prefix of all the related resources."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the resources created."
}

variable "subnet_id" {
  description = "Subnet ID where the NFS share will be allocated."
  type        = string
}

variable "mountpoint" {
  description = "Path to the directory where the NFS share will be mounted."
  type        = string
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
