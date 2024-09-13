# Copyright 2024 Canonical Ltd.
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

variable "model" {
  description = "Name of Charmed HPC cluster"
  type        = string
  default     = "charmed-hpc"
}

variable "compute-channel" {
  description = "Channel to deploy compute (slurmd) from."
  type        = string
  default     = "latest/edge"
}

variable "compute-scale" {
  description = "Scale of compute application."
  type        = number
  default     = 1
}

variable "controller-channel" {
  description = "Channel to deploy controller (slurmctld) from."
  type        = string
  default     = "latest/edge"
}

variable "controller-scale" {
  description = "Scale of controller application"
  type        = number
  default     = 1
}

variable "database-channel" {
  description = "Channel to deploy database (slurmdbd) from."
  type        = string
  default     = "latest/edge"
}

variable "database-scale" {
  description = "Scale of database application."
  type        = number
  default     = 1
}

variable "mysql-channel" {
  description = "Channel to deploy mysql from."
  type        = string
  default     = "8.0/stable"
}

variable "mysql-revision" {
  description = "Revision of mysql to deploy from channel."
  type        = number
  default     = null
}

variable "mysql-scale" {
  description = "Scale of mysql application"
  type        = number
  default     = 1
}

variable "mysql-router-channel" {
  description = "Channel to deploy mysql-router from."
  type        = string
  default     = "dpe/beta"
}

variable "mysql-router-revision" {
  description = "Revision of mysql-router to deploy from channel."
  type        = number
  default     = null
}

variable "rest-api-channel" {
  description = "Channel to deploy REST API (slurmrestd) from."
  type        = string
  default     = "latest/edge"
}

variable "rest-api-scale" {
  description = "Scale of REST API application."
  type        = number
  default     = 1
}
