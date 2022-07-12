data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server*"]
  }
  owners = [var.ubuntu_account_number]
}

data "aws_availability_zones" "available" {}

data "aws_ebs_snapshot_ids" "ipfs_data" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}${var.ipfs_snapshot_name}:${terraform.workspace}"]
  }
}

data "aws_ebs_snapshot_ids" "git_data" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}${var.git_snapshot_name}:${terraform.workspace}"]
  }
}

data "aws_acm_certificate" "cert" {
  domain = "*.${terraform.workspace}.${var.root_domain}"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.prefix}-${terraform.workspace}"
  public_key = file(var.public_key_path)
}

provider "aws" {
  region = var.workspace_regions[terraform.workspace]
}

terraform {
  backend "s3" {
    workspace_key_prefix = "gitblox"
    bucket               = "terraform-ca-state"
    key                  = "terraform.tfstate"
    region               = "us-east-1"
    encrypt              = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22.0"
    }
  }
}

