locals {
  db_types = { for v in var.db_type : v => v }

  disk_size_small  = var.disk_size == "small" ? "50" : ""
  disk_size_medium = var.disk_size == "medium" ? "100" : ""
  disk_size_large  = var.disk_size == "large" ? "200" : ""
  disk_size_gb     = coalesce(local.disk_size_small, local.disk_size_medium, local.disk_size_large)
}

data "aws_vpc" "selected" {
  tags = {
    Name  = "${var.stage}_vpc"
    Stage = "${var.stage}"
  }
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_route53_zone" "selected" {
  name         = "example.com"
  private_zone = true

  tags = {
    Stage = var.stage
  }
}

data "aws_iam_instance_profile" "ssm" {
  name = "ec2-ssm-iam-role-${var.stage}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "cloud_init" {
  for_each = local.db_types
  template = file("${path.module}/${each.value}/cloud-init.sh")
}

data "cloudinit_config" "config" {
  for_each      = local.db_types
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.cloud_init[each.value].rendered
  }
}

resource "random_pet" "name" {}

resource "aws_security_group" "allow_db_access" {
  for_each    = local.db_types
  name        = "${var.stage}-sg-${each.value}"
  description = "Allow ${each.value} inbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "${each.value} connectivity from VPC"
    from_port   = each.value == "mysql" ? var.parameter_sg_port_mysql : var.parameter_sg_port_postgres
    to_port     = each.value == "mysql" ? var.parameter_sg_port_mysql : var.parameter_sg_port_postgres
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    description      = "All all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Stage = var.stage
  }
}

resource "aws_instance" "db" {
  for_each               = local.db_types
  instance_type          = var.instance_type
  subnet_id = flatten(data.aws_subnets.selected.ids)[0]
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  iam_instance_profile   = data.aws_iam_instance_profile.ssm.name
  vpc_security_group_ids = [aws_security_group.allow_db_access[each.value].id]

  root_block_device {
    encrypted   = true
    volume_size = local.disk_size_gb
    volume_type = "gp3"
  }

  user_data = data.cloudinit_config.config[each.value].rendered

  tags = {
    Name        = "ec2-${var.stage}-${each.value}-${random_pet.name.id}"
    Stage       = var.stage
    DefaultUser = each.value == "mysql" ? var.parameter_default_usr_mysql : var.parameter_default_usr_postgres
    DefaultDB   = each.value == "mysql" ? var.parameter_default_db_mysql : var.parameter_default_db_postgres
    DomainName  = var.tag_domain_name
  }
}

resource "aws_route53_record" "record" {
  for_each = local.db_types
  zone_id  = data.aws_route53_zone.selected.zone_id
  name     = "ec2-${var.stage}-${each.value}-${random_pet.name.id}.example.com"
  type     = "A"
  ttl      = "300"
  records  = [aws_instance.db[each.value].private_ip]
}