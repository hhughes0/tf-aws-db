locals {
  vpc_cidr_dev  = var.stage == "dev" ? "10.0.0.0/16" : ""
  vpc_cidr_test = var.stage == "test" ? "10.1.0.0/16" : ""
  vpc_cidr_beta = var.stage == "beta" ? "10.2.0.0/16" : ""
  vpc_cidr_prod = var.stage == "prod" ? "10.3.0.0/16" : ""
  vpc_cidr      = coalesce(local.vpc_cidr_dev, local.vpc_cidr_test, local.vpc_cidr_beta, local.vpc_cidr_prod)
}

data "aws_iam_policy" "ssm_policy" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_region" "current" {}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr
  tags = {
    Name  = "${var.stage}_vpc"
    Stage = var.stage
  }
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = aws_vpc.main.cidr_block

  tags = {
    Name  = "${var.stage}_subnet"
    Stage = var.stage
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route53_zone" "private" {
  name = "example.com"

  vpc {
    vpc_id = aws_vpc.main.id
  }

  tags = {
    Stage = var.stage
  }
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ec2-ssm-iam-role-${var.stage}"
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role" "ssm_role" {
  name                = "iam-ec2-ssm-role-${var.stage}"
  path                = "/"
  managed_policy_arns = [data.aws_iam_policy.ssm_policy.arn]
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "ssm.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_security_group" "sg_ssm" {
  description = "Allow TLS inbound To AWS Systems Manager Session Manager"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    description = "Allow All Egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Stage = var.stage
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  subnet_ids        = [aws_subnet.main.id]
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.sg_ssm.id
  ]

  private_dns_enabled = true
  tags = {
    Stage = var.stage
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.main.id
  subnet_ids        = [aws_subnet.main.id]
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.sg_ssm.id
  ]

  private_dns_enabled = true
  tags = {
    Stage = var.stage
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.main.id
  subnet_ids        = [aws_subnet.main.id]
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.sg_ssm.id
  ]

  private_dns_enabled = true
  tags = {
    Stage = var.stage
  }
}