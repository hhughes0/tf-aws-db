locals {
  stages = { for v in var.deploy_stages : v => v }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "aws_vpc_clz" {
  for_each = local.stages

  source          = "./modules/aws-vpc-clz"
  stage = each.value
}

module "aws_ec2" {
  for_each = local.stages
  depends_on = [
    module.aws_vpc_clz
  ]
  source = "./modules/aws-ec2-db"

  stage         = each.value
  instance_type = var.instance_type[each.value]
  disk_size     = var.disk_size[each.value]
  ami_id = var.ami_id
  db_type = var.db_type
}