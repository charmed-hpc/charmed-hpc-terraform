terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.19.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.99"
    }
  }
}

provider "juju" {}

provider "aws" {}

# ==== Controller VPC information ====

variable "controller_vpc_id" {
  type        = string
  description = "VPC ID where the Juju controller is located."
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "controller" {
  id = var.controller_vpc_id
}

data "aws_subnets" "controller" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.controller.id]
  }
}

data "aws_internet_gateway" "controller" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.controller.id]
  }
}

data "aws_route_tables" "controller" {
  vpc_id = data.aws_vpc.controller.id
}

# ==== NFS VPC setup ====

module "nfs-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "nfs-vpc"
  cidr = "10.0.0.0/16"

  azs                  = [data.aws_availability_zones.available.names[0]]
  public_subnets       = ["10.0.0.16/28"]
  private_subnets      = ["10.0.1.0/24"]
  public_subnet_names  = ["NFS NAT Subnet"]
  private_subnet_names = ["NFS Main Subnet"]

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    Terraform = "true"
  }
}

resource "aws_security_group" "nfs" {
  name   = "nfs-vpc-sg"
  vpc_id = module.nfs-vpc.vpc_id

  # Allow SSH connections to the NFS VPC
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Terraform removes the default rule
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "NFS VPC allow NFS"
  }
}

# Relates the NFS VPC with the controller VPC so that Juju can access the remote machines.
resource "aws_vpc_peering_connection" "nfs-controller" {
  peer_vpc_id = module.nfs-vpc.vpc_id
  vpc_id      = data.aws_vpc.controller.id
  # `auto_accept` is only valid if both VPCs are created on the same AWS account.
  auto_accept = true
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "VPC Peering between NFS VPC and Juju controller VPC"
  }
}

# Need to add routes between the NFS VPC and the Juju controller VPC.
resource "aws_route" "nfs-route" {
  count                     = length(module.nfs-vpc.private_route_table_ids)
  route_table_id            = tolist(module.nfs-vpc.private_route_table_ids)[count.index]
  destination_cidr_block    = data.aws_vpc.controller.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.nfs-controller.id
}

# Override all route tables just to avoid having to select the correct one.
resource "aws_route" "controller-route" {
  count                     = length(data.aws_route_tables.controller.ids)
  route_table_id            = tolist(data.aws_route_tables.controller.ids)[count.index]
  destination_cidr_block    = module.nfs-vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.nfs-controller.id
}

# ==== Juju resources ====

resource "juju_model" "charmed-hpc" {
  name = "charmed-hpc"

  cloud {
    name   = "aws"
    region = data.aws_region.current.name
  }

  config = {
    "vpc-id-force" = true
    "vpc-id"       = module.nfs-vpc.vpc_id
  }
}

module "nfs-share" {
  source     = "git::https://github.com/charmed-hpc/charmed-hpc-terraform//modules/nfs/aws"
  name       = "nfs-share"
  vpc_id     = module.nfs-vpc.vpc_id
  subnet_id  = module.nfs-vpc.private_subnets[0]
  mountpoint = "/nfs/home"
  model_name = juju_model.charmed-hpc.name
}

resource "juju_machine" "ubuntu" {
  model = juju_model.charmed-hpc.name
  base  = "ubuntu@24.04"

  # Important to ensure the application is properly allocated in the correct subnet.
  placement = "subnet=${module.nfs-vpc.private_subnets_cidr_blocks[0]}"
}

resource "juju_application" "ubuntu" {
  name  = "ubuntu"
  model = juju_model.charmed-hpc.name

  charm {
    name = "ubuntu"
    base = "ubuntu@24.04"
  }

  machines = [juju_machine.ubuntu.machine_id]
}

# Since the filesystem client is a subordinate charm, it uses
# the `juju-info` endpoint to integrate with other charms.
resource "juju_integration" "ubuntu-to-filesystem-client" {
  model = juju_model.charmed-hpc.name

  application {
    name     = juju_application.ubuntu.name
    endpoint = "juju-info"
  }

  application {
    name     = module.nfs-share.app_name
    endpoint = "juju-info"
  }
}
