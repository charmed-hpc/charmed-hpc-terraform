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

## Deploy a Charmed HPC cluster.

provider "juju" {}

resource "juju_model" "charmed-hpc" {
  name = var.model
}

## Slurm - workload manager for Charmed HPC.
module "controller" {
  source = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmctld/terraform"

  model_name = juju_model.charmed-hpc.name
  app_name   = "controller"
  channel    = var.controller-channel
  units      = var.controller-scale
}

module "compute" {
  source = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmd/terraform"

  model_name = juju_model.charmed-hpc.name
  app_name   = "compute"
  channel    = var.compute-channel
  units      = var.compute-scale
}

module "database" {
  source = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmdbd/terraform"

  model_name = juju_model.charmed-hpc.name
  app_name   = "database"
  channel    = var.database-channel
  units      = var.database-scale
}

module "rest-api" {
  source = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmrestd/terraform"

  model_name = juju_model.charmed-hpc.name
  app_name   = "rest-api"
  channel    = var.rest-api-channel
  units      = var.rest-api-scale
}

## MySQL - provides backing database for `slurmdbd`.
module "mysql" {
  source = "git::https://github.com/canonical/mysql-operator//terraform"

  juju_model_name = juju_model.charmed-hpc.name
  app_name        = "mysql"
  channel         = var.mysql-channel
  units           = var.mysql-scale
}

# TODO:
#   Pull a Terraform module for mysql-router-operator once
#   it has been published to the upstream repository.
resource "juju_application" "database-mysql-router" {
  name  = "database-mysql-router"
  model = juju_model.charmed-hpc.name

  charm {
    name     = "mysql-router"
    channel  = var.mysql-router-channel
    revision = var.mysql-router-revision
  }
  units = 0 # Units should always be zero since mysql-router is a subordinate operator.
}

## Grafana Agent - forwards collected cluster metrics to COS.
module "grafana-agent" {
  source = "git::https://github.com/canonical/grafana-agent-operator//terraform"

  model_name = juju_model.charmed-hpc.name
  app_name   = "grafana-agent"
  channel    = var.grafana-agent-channel
  units      = 0 # Units should always be zero since grafana-agent is a subordinate operator.
}

## Integrate `slurmctld`, `slurmd`, `slurmdbd`, and `slurmrestd` together.
resource "juju_integration" "compute-to-controller" {
  model = juju_model.charmed-hpc.name

  application {
    name     = module.compute.app_name
    endpoint = module.compute.provides.slurmctld
  }

  application {
    name     = module.controller.app_name
    endpoint = module.controller.requires.slurmd
  }
}

resource "juju_integration" "database-to-controller" {
  model = juju_model.charmed-hpc.name

  application {
    name     = module.database.app_name
    endpoint = module.database.provides.slurmctld
  }

  application {
    name     = module.controller.app_name
    endpoint = module.controller.requires.slurmdbd
  }
}

resource "juju_integration" "rest-api-to-controller" {
  model = juju_model.charmed-hpc.name

  application {
    name     = module.rest-api.app_name
    endpoint = module.rest-api.provides.slurmctld
  }

  application {
    name     = module.controller.app_name
    endpoint = module.controller.requires.slurmrestd
  }
}

## Integrate `slurmd` with `mysql`.
resource "juju_integration" "database-to-mysql-router" {
  model = juju_model.charmed-hpc.name

  application {
    name     = juju_application.database-mysql-router.name
    endpoint = "database"
  }

  application {
    name     = module.database.app_name
    endpoint = module.database.requires.database
  }
}

resource "juju_integration" "mysql-router-to-mysql" {
  model = juju_model.charmed-hpc.name

  application {
    name     = module.mysql.application_name
    endpoint = module.mysql.provides.database
  }

  application {
    name     = juju_application.database-mysql-router.name
    endpoint = "backend-database"
  }
}

## Integrate `slurmctld` with `grafana-agent`.
resource "juju_integration" "controller-to-grafana-agent" {
  model = juju_model.charmed-hpc.name

  application {
    name = module.controller.app_name
  }

  application {
    name = module.grafana-agent.app_name
  }
}
