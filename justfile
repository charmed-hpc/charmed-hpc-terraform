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

bold := `tput bold`
normal := `tput sgr0`

[private]
default:
  @just help

# initialize charmed hpc deployment plans
init:
  #!/usr/bin/env bash
  echo "{{bold}}Initializing plan...{{normal}}"
  tofu init

# format charmed hpc deployment plans
fmt:
  tofu fmt -recursive

# check that charmed hpc deployment plans are valid
check: init
  #!/usr/bin/env bash
  tofu fmt -check -recursive
  echo "{{bold}}Validating plan...{{normal}}"
  tofu validate

# clean charmed hpc project directory
clean:
  find . -name .terraform -type d | xargs rm -rf
  find . -name .terraform.lock.hcl -type f | xargs rm -rf
  find . -name "terraform.tfstate*" -type f | xargs rm -rf

# deploy charmed hpc cluster
deploy: init
  #!/usr/bin/env bash

  # Workaround for:
  # https://github.com/juju/terraform-provider-juju/issues/573
  #
  # Deploying on AWS intermittently fails with i/o timeouts as the Juju
  # Terraform provider returns inaccessible local IP addresses in the list of
  # API controllers. Work around by determining if the current cloud is 'aws'
  # and set environment variable 'JUJU_CONTROLLER_ADDRESSES' to the non-local
  # endpoint(s) if so.
  #
  # For example, controller configuration:
  #
  #   cloud: aws
  #   api_endpoints = ['44.192.113.5:17070', '172.31.11.216:17070',
  #                    '252.11.216.1:17070']
  #
  # results in:
  #
  #   export JUJU_CONTROLLER_ADDRESSES=44.192.113.5:17070
  #
  # Check if deploying on AWS
  cont_config=$(juju show-controller)
  cloud="$(echo "$cont_config" | grep -oP "cloud: \K\w+")"

  if [ "$cloud" = "aws" ]; then
    # Filter out local IP addresses from API endpoints
    api_endpoints="$(echo "$cont_config" | grep -oP "api-endpoints: \[\K[^]]+")"

    valid_endpoints="$(
      echo $api_endpoints |     # e.g. "'1.2.3.4:17070', '172.1.2.3:17070'"
      grep -oP "'\S+'" |        # Match non-whitespace between single quotes
      grep -vE "^'172|^'252" |  # Exclude local IPs
      sed "s/'//g" |            # Remove single quotes from remaining entries
      paste -sd "," -           # Join entries into comma-separated string
    )"

    # Apply only if endpoints list is non-empty, i.e. at least one valid
    # endpoint was found.
    if [ -n "$valid_endpoints" ]; then
      export JUJU_CONTROLLER_ADDRESSES="$valid_endpoints"
    fi
  fi
  # End of workaround

  tofu plan
  tofu apply -auto-approve

# *Unfinished: does not run* as "deploy" above but using Python in-line
deploy-python: init
  #!/usr/bin/env python
  import json
  import subprocess

  # Check if deploying on AWS
  result = subprocess.check_output("juju show-controller --format json".split(),
                                  stderr=subprocess.STDOUT, text=True)
  juju_config = json.loads(result)
  # Expect dictionary with single key corresponding to current controller name
  controller_name = list(juju_config.keys())[0]
  cloud = juju_config[controller_name]["details"]["cloud"]

  if cloud == "aws":
      # Filter out local IP addresses from list of all API endpoints
      endpoints = juju_config[controller_name]["details"]["api-endpoints"]
      valid_endpoints = ""
      for endpoint in endpoints:
          # Local IPs defined as those in 172.x and 252.x ranges
          if not(endpoint.startswith(("172","252"))):
              valid_endpoints += endpoint + ","
      valid_endpoints = valid_endpoints.rstrip(",")

  # TODO: appropriately set JUJU_CONTROLLER_ADDRESSES and run tofu plan/apply

# destroy charmed hpc cluster deployed
destroy:
  #!/usr/bin/env bash
  tofu apply -destroy -auto-approve

# show available recipes
help:
  @just --list --unsorted
