# Terraform module for Slurm Core

This is a Terraform module facilitating the deployment of the core components of a Slurm-based HPC cluster.

## API

### Inputs

This module offers the following configurable units:

| Name                          | Type        | Description                                                       | Default                        | Required |
|-------------------------------|-------------|-------------------------------------------------------------------|--------------------------------|:--------:|
| `model_name`                  | string      | Name of the target Juju model                                     |                                |    Y     |
| `database_backend`            | object      | Information about the application provisioning the Slurm database |                                |    Y     |
| `channel`                     | string      | Channel to deploy the Slurm charms from                           | "latest/edge"                  |          |
| `controller`                  | object      | Configuration options for the Slurm controller node               | `{ app_name = "controller" }`  |          |
| `database`                    | object      | Configuration options for the Slurm database node                 | `{ app_name = "database" }`    |          |
| `rest_api`                    | object      | Configuration options for the Slurm REST API node                 | `{ app_name = "rest-api" }`    |          |
| `kiosk`                       | object      | Configuration options for the Slurm kiosk node                    | `{ app_name = "login-node" }`  |          |
| `compute_partitions`          | map(object) | Map of Slurm compute partitions to deploy                         | `{ "compute": { units = 1 } }` |          |

### Outputs

After applying, the module exports the following outputs:

| Name                 | Description                                        |
|----------------------|----------------------------------------------------|
| `controller`         | Information about the Slurm controller application |
| `database`           | Information about the Slurm database application.  |
| `rest_api`           | Information about the Slurm REST API application.  |
| `kiosk`              | Information about the Slurm kiosk application.     |
| `compute_partitions` | Information about the Slurm partitions.            |

## Usage

See the [`slurm`](../../examples/slurm/main.tf) example for an usage example.
