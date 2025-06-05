# Terraform module for Azure managed NFS

This is a Terraform module facilitating the deployment of an NFS share managed by Azure, and the
corresponding proxy and client charms to mount the filesystem on Juju machines.

## API

### Inputs

This module offers the following configurable units:

| Name                          | Type        | Description                                               | Default       | Required |
|-------------------------------|-------------|-----------------------------------------------------------|---------------|:--------:|
| `name`                        | string      | Name for the exported NFS share                           |               |    Y     |
| `quota`                       | number      | Maximum size of the share, in gigabytes                   |               |    Y     |
| `mountpoint`                  | string      | Path to the directory where the NFS share will be mounted |               |    Y     |
| `resource_group_name`         | string      | Name of the Azure resource group                          |               |    Y     |
| `subnet_info`                 | string      | Subnet information used to create the NFS share           |               |    Y     |
| `model_name`                  | string      | Name of the target Juju model                             |               |    Y     |
| `nfs_server_proxy_channel`    | string      | Channel to deploy the nfs-server-proxy charm from         | "latest/edge" |          |
| `filesystem_client_channel`   | string      | Channel to deploy the filesystem-client charm from        | "latest/edge" |          |

### Outputs

After applying, the module exports the following outputs:

| Name       | Description                                                                       |
|------------|-----------------------------------------------------------------------------------|
| `app_name` | Application name for the `filesystem-client` that is ready to mount the NFS share |

## Usage

Since this module uses version 4.0 of the Azure Provider, it requires specifying the Azure Subscription ID
before configuring the provider instance. This can be done by setting the `ARM_SUBSCRIPTION_ID` environment
variable:

```shell
# Bash etc.
export ARM_SUBSCRIPTION_ID=00000000-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```
