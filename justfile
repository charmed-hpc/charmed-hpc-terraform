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
  for plan in plans/*/; do
    echo "{{bold}}Initializing plan $(basename ${plan})...{{normal}}"
    tofu -chdir=${plan} init
  done

# format charmed hpc deployment plans
fmt:
  tofu fmt -recursive

# check that charmed hpc deployment plans are valid
check: init
  #!/usr/bin/env bash
  tofu fmt -check -recursive
  for plan in plans/*/; do
    echo "{{bold}}Validating plan $(basename ${plan})...{{normal}}"
    tofu -chdir=${plan} validate
  done

# clean charmed hpc project directory
clean:
  find . -name .terraform -type d | xargs rm -rf
  find . -name .terraform.lock.hcl -type f | xargs rm -rf
  find . -name "terraform.tfstate*" -type f | xargs rm -rf

[private]
_exists target:
  #!/usr/bin/env bash
  if [[ ! -d "plans/{{target}}" ]]; then
    echo "{{bold}}{{target}}{{normal}} is not a valid Charmed HPC deployment plan"
    exit 1
  fi

# deploy charmed hpc cluster using plan `target`
deploy target: (_exists target)
  #!/usr/bin/env bash
  cd plans/{{target}}
  tofu init
  tofu plan
  tofu apply -auto-approve

# destroy charmed hpc cluster deployed using plan `target`
destroy target: (_exists target)
  #!/usr/bin/env bash
  cd plans/{{target}}
  tofu apply -destroy -auto-approve

# show available recipes
help:
  @just --list --unsorted
