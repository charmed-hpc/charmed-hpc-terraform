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
  share_name = replace(substr(var.name, 0, 10), "-", "_")
}

resource "google_filestore_instance" "nfs" {
  name     = "${var.name}-filestore"
  location = var.location
  tier     = var.tier
  protocol = "NFS_V3"

  file_shares {
    name        = local.share_name
    capacity_gb = var.capacity_gb
  }

  networks {
    network = var.network
    modes   = ["MODE_IPV4"]
  }
}

resource "juju_application" "nfs-server-proxy" {
  name  = "${var.name}-server"
  model = var.model_name

  charm {
    name    = "nfs-server-proxy"
    channel = var.nfs_server_proxy_channel
    base    = "ubuntu@24.04"
  }

  config = {
    "hostname" : google_filestore_instance.nfs.networks[0].ip_addresses[0]
    "path" : "/${local.share_name}"
  }

}

module "filesystem-client" {
  source = "git::https://github.com/charmed-hpc/filesystem-charms//charms/filesystem-client/terraform"

  app_name   = "${var.name}-client"
  model_name = var.model_name
  channel    = var.filesystem_client_channel
  config = {
    "mountpoint" : var.mountpoint
  }
}

resource "juju_integration" "nfs" {
  model = var.model_name

  application {
    name     = juju_application.nfs-server-proxy.name
    endpoint = "filesystem"
  }

  application {
    name     = module.filesystem-client.app_name
    endpoint = module.filesystem-client.requires.filesystem
  }

  depends_on = [juju_application.nfs-server-proxy]
}
