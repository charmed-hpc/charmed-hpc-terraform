# AWS managed NFS server in Juju

This example shows how to create and deploy an isolated Virtual Public Cloud (VPC) which has
access to an NFS server, and how to deploy applications in the VPC using Juju. In order to enable
deploying resources in AWS, read the [Usage section in modules/nfs/aws/README.md](../../../modules/nfs/aws/README.md#usage)

## Inputs

|        Name       |                            Description                           |
|-------------------|------------------------------------------------------------------|
| controller_vpc_id | VPC ID where the Juju controller for the AWS cloud is allocated. |

Any variable can be set using environment variables:

```bash
export TF_VAR_<variable_name>=<variable-value>
```

The VPC ID of the controller can be obtained by getting the configuration for the controller model
(if the controller was not bootstrapped in the default VPC):

```bash
juju model-config -m controller
```

Otherwise, the ID for the default VPC can be obtained through [AWS][aws-guide].

[aws-guide]: https://docs.aws.amazon.com/vpc/latest/userguide/work-with-default-vpc.html#view-default-vpc

Finally, the `controller_vpc_id` variable can be provided using environment variables:

```bash
export TF_VAR_controller_vpc_id=vpc-xxxxxxxxxxxxxx
```

## Usage

To run this example, execute:

```bash
terraform init
terraform plan
terraform apply
```

## Permissions

The AWS user associated with the access key requires a set of permissions for deploying, modifying, and
deleting the required resources. See [Change permissions for an IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_change-permissions.html)
for more information on how to setup permissions.
An example policy that can be used to successfully deploy the Terraform example is provided here, but note that any additional
resources could require more permissions than the ones specified here.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:AcceptAddressTransfer",
                "ec2:AcceptVpcPeeringConnection",
                "ec2:AllocateAddress",
                "ec2:AssignIpv6Addresses",
                "ec2:AssignPrivateIpAddresses",
                "ec2:AssignPrivateNatGatewayAddress",
                "ec2:AssociateAddress",
                "ec2:AssociateIamInstanceProfile",
                "ec2:AssociateNatGatewayAddress",
                "ec2:AssociateRouteTable",
                "ec2:AssociateSubnetCidrBlock",
                "ec2:AttachInternetGateway",
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateDefaultSubnet",
                "ec2:CreateDefaultVpc",
                "ec2:CreateEgressOnlyInternetGateway",
                "ec2:CreateInternetGateway",
                "ec2:CreateNatGateway",
                "ec2:CreateNetworkAcl",
                "ec2:CreateNetworkAclEntry",
                "ec2:CreateRoute",
                "ec2:CreateRouteTable",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSubnet",
                "ec2:CreateSubnetCidrReservation",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateVpc",
                "ec2:CreateVpcPeeringConnection",
                "ec2:DeleteEgressOnlyInternetGateway",
                "ec2:DeleteInternetGateway",
                "ec2:DeleteNatGateway",
                "ec2:DeleteNetworkAcl",
                "ec2:DeleteNetworkAclEntry",
                "ec2:DeleteRoute",
                "ec2:DeleteRouteTable",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteSubnet",
                "ec2:DeleteSubnetCidrReservation"
                "ec2:DeleteVolume",
                "ec2:DeleteVpc",
                "ec2:DeleteVpcPeeringConnection",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeAddressesAttribute",
                "ec2:DescribeAddressTransfers",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeEgressOnlyInternetGateways",
                "ec2:DescribeIamInstanceProfileAssociations",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypeOfferings",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeMovingAddresses",
                "ec2:DescribeNatGateways",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroupRules",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSpotPriceHistory",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeVpcPeeringConnections",
                "ec2:DescribeVpcs",
                "ec2:DetachInternetGateway",
                "ec2:DetachVolume",
                "ec2:DisableAddressTransfer",
                "ec2:DisableRouteServerPropagation",
                "ec2:DisableTransitGatewayRouteTablePropagation",
                "ec2:DisableVgwRoutePropagation",
                "ec2:DisassociateAddress",
                "ec2:DisassociateNatGatewayAddress",
                "ec2:DisassociateRouteTable",
                "ec2:DisassociateSubnetCidrBlock",
                "ec2:EnableAddressTransfer",
                "ec2:EnableRouteServerPropagation",
                "ec2:EnableTransitGatewayRouteTablePropagation",
                "ec2:EnableVgwRoutePropagation",
                "ec2:GetRouteServerPropagations",
                "ec2:GetSubnetCidrReservations",
                "ec2:GetTransitGatewayAttachmentPropagations",
                "ec2:GetTransitGatewayRouteTablePropagations",
                "ec2:ModifyAddressAttribute",
                "ec2:ModifySubnetAttribute",
                "ec2:ModifyVpcAttribute",
                "ec2:ModifyVpcPeeringConnectionOptions",
                "ec2:MoveAddressToVpc",
                "ec2:RejectVpcPeeringConnection",
                "ec2:ReleaseAddress",
                "ec2:ReplaceNetworkAclAssociation",
                "ec2:ReplaceNetworkAclEntry",
                "ec2:ReplaceRoute",
                "ec2:ReplaceRouteTableAssociation",
                "ec2:ResetAddressAttribute",
                "ec2:RestoreAddressToClassic",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ec2:UnassignIpv6Addresses",
                "ec2:UnassignPrivateIpAddresses",
                "ec2:UnassignPrivateNatGatewayAddress",
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:CreateAccessPoint",
                "elasticfilesystem:CreateFileSystem",
                "elasticfilesystem:CreateMountTarget",
                "elasticfilesystem:CreateReplicationConfiguration",
                "elasticfilesystem:CreateTags",
                "elasticfilesystem:DeleteAccessPoint",
                "elasticfilesystem:DeleteFileSystem",
                "elasticfilesystem:DeleteFileSystemPolicy",
                "elasticfilesystem:DeleteMountTarget",
                "elasticfilesystem:DeleteReplicationConfiguration",
                "elasticfilesystem:DeleteTags",
                "elasticfilesystem:DescribeAccessPoints",
                "elasticfilesystem:DescribeAccountPreferences",
                "elasticfilesystem:DescribeBackupPolicy",
                "elasticfilesystem:DescribeFileSystemPolicy",
                "elasticfilesystem:DescribeFileSystems",
                "elasticfilesystem:DescribeLifecycleConfiguration",
                "elasticfilesystem:DescribeMountTargets",
                "elasticfilesystem:DescribeMountTargetSecurityGroups",
                "elasticfilesystem:DescribeReplicationConfigurations",
                "elasticfilesystem:DescribeTags",
                "elasticfilesystem:ListTagsForResource",
                "elasticfilesystem:ModifyMountTargetSecurityGroups",
                "elasticfilesystem:PutBackupPolicy",
                "elasticfilesystem:PutFileSystemPolicy",
                "elasticfilesystem:PutLifecycleConfiguration",
                "elasticfilesystem:TagResource",
                "elasticfilesystem:UntagResource",
                "elasticfilesystem:UpdateFileSystem"
                "elasticfilesystem:UpdateFileSystemProtection",
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "iam:AddRoleToInstanceProfile",
                "iam:CreateInstanceProfile",
                "iam:CreateRole",
                "iam:DeleteInstanceProfile",
                "iam:DeleteRole",
                "iam:DeleteRolePolicy",
                "iam:GetInstanceProfile",
                "iam:GetRole",
                "iam:ListInstanceProfiles",
                "iam:ListRolePolicies"
                "iam:ListRoles",
                "iam:PassRole",
                "iam:PutRolePolicy",
                "iam:RemoveRoleFromInstanceProfile",
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters",
                "ssm:ListInstanceAssociations"
                "ssm:UpdateInstanceInformation",
            ],
            "Resource": "*"
        }
    ]
}
```
