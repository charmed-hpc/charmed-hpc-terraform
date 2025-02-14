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

output "controller" {
  description = "Information about the Slurm controller application."
  value = {
    app_name = module.slurmctld.app_name
    requires = module.slurmctld.requires
  }
}
output "database" {
  description = "Information about the Slurm database application."
  value = {
    app_name = module.slurmdbd.app_name
    provides = module.slurmdbd.provides
    requires = module.slurmdbd.requires
  }
}
output "rest_api" {
  description = "Information about the Slurm REST API application."
  value = {
    app_name = module.slurmrestd.app_name
    provides = module.slurmrestd.provides
  }
}
output "kiosk" {
  description = "Information about the Slurm kiosk application."
  value = {
    app_name = module.sackd.app_name
    provides = module.slurmrestd.provides
  }
}

output "compute_partitions" {
  description = "Information about the Slurm compute partitions."
  value = {
    for key, value in module.slurmd_partitions : key => {
      app_name = value.app_name,
      provides = value.provides
    }
  }
}
