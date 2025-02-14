terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.16.0"
    }
  }
}

provider "juju" {}

resource "juju_model" "charmed-hpc" {
  name = "charmed-hpc"
}

## MySQL - provides backing database for the accounting node.
module "mysql" {
  source = "git::https://github.com/canonical/mysql-operator//terraform"

  juju_model_name = juju_model.charmed-hpc.name
  app_name        = "mysql"
  channel         = "8.0/stable"
  units           = 1
}

module "slurm" {
  source = "git::https://github.com/charmed-hpc/charmed-hpc-terraform//modules/slurm"

  model_name = juju_model.charmed-hpc.name
  database_backend = {
    name     = module.mysql.application_name,
    endpoint = module.mysql.provides.database
  }

  # Optional settings for the controller node.
  controller = {
    app_name = "slurmctld"
  }

  # Optional settings for the database node.
  database = {
    app_name = "slurmdbd"
  }

  # Optional settings for the REST API node.
  rest_api = {
    app_name = "slurmrestd"
  }

  # Optional settings for the kiosk node.
  kiosk = {
    app_name = "sackd",
    units    = 1,
  }

  # Compute partitions to be deployed.
  compute_partitions = {
    "default" : {
      units = 1,
    },
    "gpu" : {
      units = 1,
    }
  }
  depends_on = [
    juju_model.charmed-hpc
  ]
}
