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

data "juju_model" "this" {
  name = var.model_name
}

data "juju_application" "mysql" {
  name  = var.database_backend.name
  model = coalesce(var.database_backend.model, data.juju_model.this.name)
}

# Setup control plane

module "slurmctld" {
  source = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmctld/terraform"

  model_name  = data.juju_model.this.name
  app_name    = var.controller.app_name
  channel     = var.channel
  units       = 1
  config      = var.controller.config
  constraints = var.controller.constraints
}

module "slurmdbd" {
  source = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmdbd/terraform"

  model_name  = data.juju_model.this.name
  app_name    = var.database.app_name
  channel     = var.channel
  units       = 1
  config      = var.database.config
  constraints = var.database.constraints
}

module "slurmrestd" {
  source = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmrestd/terraform"

  model_name  = data.juju_model.this.name
  app_name    = var.rest_api.app_name
  channel     = var.channel
  units       = 1
  config      = var.rest_api.config
  constraints = var.rest_api.constraints
}

module "sackd" {
  source = "git::https://github.com/charmed-hpc/slurm-charms//charms/sackd/terraform"

  model_name  = data.juju_model.this.name
  app_name    = var.kiosk.app_name
  channel     = var.channel
  units       = var.kiosk.units
  config      = var.kiosk.config
  constraints = var.kiosk.constraints
}

resource "juju_integration" "sackd-to-slurmctld" {
  model = data.juju_model.this.name

  application {
    name     = module.sackd.app_name
    endpoint = module.sackd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.app_name
    endpoint = module.slurmctld.requires.login-node
  }
}

resource "juju_integration" "slurmdbd-to-slurmctld" {
  model = data.juju_model.this.name

  application {
    name     = module.slurmdbd.app_name
    endpoint = module.slurmdbd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.app_name
    endpoint = module.slurmctld.requires.slurmdbd
  }
}

resource "juju_integration" "slurmrestd-to-slurmctld" {
  model = var.model_name

  application {
    name     = module.slurmrestd.app_name
    endpoint = module.slurmrestd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.app_name
    endpoint = module.slurmctld.requires.slurmrestd
  }
}

resource "juju_integration" "slurmdbd-to-mysql" {
  model = data.juju_model.this.name

  application {
    name     = module.slurmdbd.app_name
    endpoint = module.slurmdbd.requires.database
  }

  application {
    name     = data.juju_application.mysql.name
    endpoint = var.database_backend.endpoint
  }
}

# Setup compute plane

module "slurmd_partitions" {
  for_each = var.compute_partitions
  source   = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmd/terraform"

  model_name  = data.juju_model.this.name
  app_name    = each.key
  channel     = var.channel
  units       = each.value.units
  config      = each.value.config
  constraints = each.value.constraints
}

resource "juju_integration" "slurmd-to-slurmctld" {
  for_each = module.slurmd_partitions
  model    = data.juju_model.this.name

  application {
    name     = each.value.app_name
    endpoint = each.value.provides.slurmctld
  }

  application {
    name     = module.slurmctld.app_name
    endpoint = module.slurmctld.requires.slurmd
  }
}
