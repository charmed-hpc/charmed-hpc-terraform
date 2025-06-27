terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.19.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~>6.41"
    }
  }
}

provider "juju" {}

provider "google" {}

data "google_client_config" "current" {}

# ==== Juju resources ====

resource "juju_model" "charmed-hpc" {
  name = "charmed-hpc"

  cloud {
    name   = "google"
    region = data.google_client_config.current.region
  }
}

module "nfs-share" {
  source      = "../../../modules/nfs/gcp"
  capacity_gb = 1024
  tier        = "STANDARD"
  network     = "default"
  name        = "nfs-share"
  mountpoint  = "/nfs/home"
  model_name  = juju_model.charmed-hpc.name
}

resource "juju_application" "ubuntu" {
  name  = "ubuntu"
  model = juju_model.charmed-hpc.name

  charm {
    name = "ubuntu"
    base = "ubuntu@24.04"
  }
}

# Since the filesystem client is a subordinate charm, it uses
# the `juju-info` endpoint to integrate with other charms.
resource "juju_integration" "ubuntu-to-filesystem-client" {
  model = juju_model.charmed-hpc.name

  application {
    name     = juju_application.ubuntu.name
    endpoint = "juju-info"
  }

  application {
    name     = module.nfs-share.app_name
    endpoint = "juju-info"
  }
}
