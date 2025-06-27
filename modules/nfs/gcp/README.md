# Terraform module for GCP managed NFS

This is a Terraform module facilitating the deployment of an NFS share managed by Google Cloud Platform (GCP), and the
corresponding proxy and client charms to mount the filesystem on Juju machines.

## API

### Inputs

This module offers the following configurable units:

| Name                        | Type   | Description                                                     | Default       | Required |
| --------------------------- | ------ | --------------------------------------------------------------- | ------------- | :------: |
| `name`                      | string | Name for the exported NFS share                                 | "nfs-share"   |          |
| `network`                   | string | Name of the VPC Network where the NFS instance will be emplaced |               |    Y     |
| `location`                  | string | Name of the location where the NFS instance will be emplaced    | null          |          |
| `tier`                      | string | Service tier of the NFS instance                                |               |    Y     |
| `capacity_gb`               | number | File share capacity in GiB                                      |               |    Y     |
| `mountpoint`                | string | Path to the directory where the NFS share will be mounted       |               |    Y     |
| `model_name`                | string | Name of the target Juju model                                   |               |    Y     |
| `nfs_server_proxy_channel`  | string | Channel to deploy the nfs-server-proxy charm from               | "latest/edge" |          |
| `filesystem_client_channel` | string | Channel to deploy the filesystem-client charm from              | "latest/edge" |          |

### Outputs

After applying, the module exports the following outputs:

| Name       | Description                                                                       |
| ---------- | --------------------------------------------------------------------------------- |
| `app_name` | Application name for the `filesystem-client` that is ready to mount the NFS share |

## Usage

This module requires authenticating against GCP before configuring the provider instance, and setting up the
default GCP project, region and zone. You can create a new set of credentials for the Terraform
provider by following:

- [Create service accounts](https://cloud.google.com/iam/docs/service-accounts-create#gcloud)
  to create a new service account.
- [Grant or revoke a single IAM role](https://cloud.google.com/iam/docs/granting-changing-revoking-access#single-role)
  to grant the correct roles to the service account.
  This module only requires the `roles/file.editor` role, but if you are planning to share
  the same service account with Juju, it will additionally require the `roles/compute.instanceAdmin.v1`
  and `roles/compute.securityAdmin` roles.
- [Create a service account key](https://cloud.google.com/iam/docs/keys-create-delete#creating)
  to generate the required credentials file.

After following those guides, you can provide all the required information to the Terraform provider by
setting the following environment variables:

```shell
# Bash etc.
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/creds.json
export GOOGLE_PROJECT=my-project
export GOOGLE_REGION=us-east1
export GOOGLE_ZONE=us-east1-b
```

The last three environment variables can alternatively be set directly in the provider declaration:

```terraform
provider "google" {
  project = "my-project"
  region  = "us-east1"
  zone    = "us-east1-b"
}

# ... Resources
```
