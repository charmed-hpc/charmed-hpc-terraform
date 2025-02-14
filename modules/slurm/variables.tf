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

variable "model_name" {
  description = "Name of the target Juju model."
  type        = string
  nullable    = false
}

variable "database_backend" {
  description = "Information about the charm application provisioning the Slurm database."
  type = object({
    name     = string,
    endpoint = string,
    model    = optional(string),
  })
  nullable = false
}


variable "channel" {
  description = "Channel to deploy the Slurm charms from."
  type        = string
  default     = "latest/edge"
  nullable    = false
}

variable "controller" {
  description = "Configuration options for the Slurm controller node."
  type = object({
    app_name    = optional(string),
    config      = optional(map(string)),
    constraints = optional(string)
  })
  nullable = false
  default = {
    app_name = "controller"
  }
}

variable "database" {
  description = "Configuration options for the Slurm database node."
  type = object({
    app_name    = optional(string),
    config      = optional(map(string)),
    constraints = optional(string)
  })
  nullable = false
  default = {
    app_name = "database"
  }
}

variable "rest_api" {
  description = "Configuration options for the Slurm REST API node."
  type = object({
    app_name    = optional(string),
    config      = optional(map(string)),
    constraints = optional(string)
  })
  nullable = false
  default = {
    app_name = "rest-api"
  }
}

variable "kiosk" {
  description = "Configuration options for the Slurm kiosk node."
  type = object({
    app_name    = optional(string),
    units       = optional(number),
    config      = optional(map(string)),
    constraints = optional(string)
  })
  nullable = false
  default = {
    app_name = "login-node"
    units    = 1
  }
}

variable "compute_partitions" {
  description = "Map of Slurm compute partitions to deploy."
  type = map(
    object({
      units       = optional(number),
      config      = optional(map(string)),
      constraints = optional(string)
    })
  )
  default = {
    "compute" : {
      units = 1
    }
  }
}
