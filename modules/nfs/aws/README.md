# Terraform module for AWS managed NFS

This is a Terraform module facilitating the deployment of an NFS share managed by Amazon Web Services (AWS), and the
corresponding proxy and client charms to mount the filesystem on Juju machines.

## API

### Inputs

This module offers the following configurable units:

| Name                          | Type        | Description                                               | Default       | Required |
|-------------------------------|-------------|-----------------------------------------------------------|---------------|:--------:|
| `name`                        | string      | Name for the exported NFS share                           |               |    Y     |
| `vpc_id`                      | string      | VPC ID for the resources created                          |               |    Y     |
| `subnet_id`                   | string      | Subnet ID where the NFS share and proxy will be allocated |               |    Y     |
| `mountpoint`                  | string      | Path to the directory where the NFS share will be mounted |               |    Y     |
| `model_name`                  | string      | Name of the target Juju model                             |               |    Y     |
| `nfs_server_proxy_channel`    | string      | Channel to deploy the nfs-server-proxy charm from         | "latest/edge" |          |
| `filesystem_client_channel`   | string      | Channel to deploy the filesystem-client charm from        | "latest/edge" |          |

### Outputs

After applying, the module exports the following outputs:

| Name       | Description                                                                       |
|------------|-----------------------------------------------------------------------------------|
| `app_name` | Application name for the `filesystem-client` that is ready to mount the NFS share |

## Usage

This module requires authenticating against AWS before configuring the provider instance. This can be done by setting
the following environment variables:

```shell
# Bash etc.
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
export AWS_REGION="us-east-1"
```
