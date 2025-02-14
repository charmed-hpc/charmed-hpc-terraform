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
# limitations under the License.\
# Necessary to use `||` logical operator.

set unstable := true

project_dir := justfile_directory()
modules_dir := project_dir / "modules"
default_module_list := shell("ls -d -- $1/*", modules_dir)

[private]
default:
    @just help

# Initialize Terraform modules
[group("terraform")]
init *modules:
    #!/usr/bin/env bash
    set -euxo pipefail
    modules=({{ prepend(modules_dir, modules) || default_module_list }})
    for module in ${modules}; do
        tofu -chdir=${module} init
    done

# Validate Terraform modules
[group("terraform")]
validate *modules: (init modules)
    #!/usr/bin/env bash
    set -euxo pipefail
    modules=({{ prepend(modules_dir, modules) || default_module_list }})
    for module in ${modules}; do
        tofu -chdir=${module} fmt -check
        tofu -chdir=${module} validate
    done

# Apply formatting standards to project
[group("dev")]
fmt:
    just --fmt --unstable
    tofu fmt -recursive

# Clean project directory
[group("dev")]
clean:
    find . -name .terraform -type d | xargs rm -rf
    find . -name .terraform.lock.hcl -type f | xargs rm -rf
    find . -name "terraform.tfstate*" -type f | xargs rm -rf

# show available recipes
help:
    @just --list --unsorted
