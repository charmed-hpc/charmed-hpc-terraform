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

locals {
  controller_machines = length(var.controller.machines) == 0
  database_machines   = length(var.database.machines) == 0
  rest_api_machines   = length(var.rest_api.machines) == 0
  kiosk_machines      = length(var.kiosk.machines) == 0
}

# slurmdbd and slurmrestd do not support HA setups
resource "terraform_data" "single_unit_services" {
  lifecycle {
    precondition {
      condition     = coalesce(var.database.units, 1) <= 1 && length(var.database.machines) <= 1
      error_message = "The Slurm database charm (slurmdbd) does not support HA setups and must be deployed with at most one unit or machine."
    }

    precondition {
      condition     = coalesce(var.rest_api.units, 1) <= 1 && length(var.rest_api.machines) <= 1
      error_message = "The Slurm REST API charm (slurmrestd) does not support HA setups and must be deployed with at most one unit or machine."
    }
  }
}

module "slurmctld" {
  source = "git::https://github.com/canonical/slurm-charms//charms/slurmctld/terraform?ref=9943f751b39268c24167ccddf9dc7145ce69cdae"

  model_uuid = var.model_uuid
  app_name   = var.controller.app_name
  base       = var.base

  channel     = var.channel
  machines    = local.controller_machines ? null : var.controller.machines
  units       = local.controller_machines ? coalesce(var.controller.units, 1) : null
  config      = var.controller.config
  constraints = var.controller.constraints
}

module "slurmdbd" {
  source = "git::https://github.com/canonical/slurm-charms//charms/slurmdbd/terraform?ref=9943f751b39268c24167ccddf9dc7145ce69cdae"

  model_uuid = var.model_uuid
  app_name   = var.database.app_name
  base       = var.base

  channel     = var.channel
  machines    = local.database_machines ? null : var.database.machines
  units       = local.database_machines ? coalesce(var.database.units, 1) : null
  config      = var.database.config
  constraints = var.database.constraints
}

module "slurmrestd" {
  source = "git::https://github.com/canonical/slurm-charms//charms/slurmrestd/terraform?ref=9943f751b39268c24167ccddf9dc7145ce69cdae"

  model_uuid = var.model_uuid
  app_name   = var.rest_api.app_name
  base       = var.base

  channel     = var.channel
  machines    = local.rest_api_machines ? null : var.rest_api.machines
  units       = local.rest_api_machines ? coalesce(var.rest_api.units, 1) : null
  config      = var.rest_api.config
  constraints = var.rest_api.constraints
}

module "sackd" {
  source = "git::https://github.com/canonical/slurm-charms//charms/sackd/terraform?ref=9943f751b39268c24167ccddf9dc7145ce69cdae"

  model_uuid = var.model_uuid
  app_name   = var.kiosk.app_name
  base       = var.base

  channel     = var.channel
  machines    = local.kiosk_machines ? null : var.kiosk.machines
  units       = local.kiosk_machines ? coalesce(var.kiosk.units, 1) : null
  config      = var.kiosk.config
  constraints = var.kiosk.constraints
}

resource "juju_integration" "sackd-to-slurmctld" {
  model_uuid = var.model_uuid

  application {
    name     = module.sackd.application.name
    endpoint = module.sackd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.application.name
    endpoint = module.slurmctld.requires.sackd
  }
}

resource "juju_integration" "slurmdbd-to-slurmctld" {
  model_uuid = var.model_uuid

  application {
    name     = module.slurmdbd.application.name
    endpoint = module.slurmdbd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.application.name
    endpoint = module.slurmctld.requires.slurmdbd
  }
}

resource "juju_integration" "slurmrestd-to-slurmctld" {
  model_uuid = var.model_uuid

  application {
    name     = module.slurmrestd.application.name
    endpoint = module.slurmrestd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.application.name
    endpoint = module.slurmctld.requires.slurmrestd
  }
}

resource "juju_integration" "slurmdbd-to-mysql" {
  model_uuid = var.model_uuid

  application {
    name     = module.slurmdbd.application.name
    endpoint = module.slurmdbd.requires.database
  }

  application {
    name     = var.database_backend.name
    endpoint = var.database_backend.endpoint
  }
}

# Setup compute plane

module "slurmd_partitions" {
  for_each = var.compute_partitions
  source   = "git::https://github.com/canonical/slurm-charms//charms/slurmd/terraform?ref=9943f751b39268c24167ccddf9dc7145ce69cdae"

  model_uuid = var.model_uuid
  app_name   = each.key
  base       = var.base

  channel     = var.channel
  machines    = length(each.value.machines) == 0 ? null : each.value.machines
  units       = length(each.value.machines) == 0 ? coalesce(each.value.units, 1) : null
  config      = each.value.config
  constraints = each.value.constraints
}

resource "juju_integration" "slurmd-to-slurmctld" {
  for_each   = module.slurmd_partitions
  model_uuid = var.model_uuid

  application {
    name     = each.value.application.name
    endpoint = each.value.provides.slurmctld
  }

  application {
    name     = module.slurmctld.application.name
    endpoint = module.slurmctld.requires.slurmd
  }
}
