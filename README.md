# tf-aws-db

Terraform to create EC2 DB(Mysql or Postgres) instance(s) on AWS.

## Usage

### Single EC2 Instance running Postgres in Stage: test

```hcl
terraform apply -var 'db_type=["postgres"]' -var 'stages=["test"]' 
```

### Multiple EC2 Instances running Postgres in Stage: test and beta

```hcl
terraform apply -var 'db_type=["postgres"]' -var 'stages=["test","beta"]' 
```

### 1 EC2 Instance running Postgres and 1 EC2 instance running mysql in Stage: test and beta

```hcl
terraform apply -var 'db_type=["postgres", "mysql"]' -var 'stages=["test","beta"]' 
```

### 1 EC2 Instance running Postgres and 1 EC2 instance running mysql in Stage: test and beta with a specific ami

```hcl
terraform apply -var 'db_type=["postgres", "mysql"]' -var 'deploy_stages=["test","beta"]' -var 'ami_id="ami-123456789101213"'
```

### 1 EC2 Instance running Postgres in Stage: test and beta with disk size specified for each stage

```hcl
terraform apply -var 'db_type=["postgres", "mysql"]' -var 'deploy_stages=["test","beta"]' -var 'disk_size={test = "large", beta = "small"}'
```

### 1 EC2 Instance running Postgres in Stage: test and beta with instance type specified

```hcl
terraform apply -var 'db_type=["postgres", "mysql"]' -var 'deploy_stages=["test","beta"]' -var 'instance_type={test = "t3.large", beta = "t3.micro"}'
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.57 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | >= 2.2.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.1.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |
| <a name="provider_template"></a> [template](#provider\_template) | >= 2.2.0 |

## Modules

| Name |
|------|
| aws-ec2-db |
| aws-vpc-clz |

## Inputs

| Name | Description | Type | Default | Required | Allowed Values |
|------|-------------|------|---------|---------|:--------:|
| deploy_stages | The different stages you want to deploy to | `list(string)` | `null`  | yes | ["dev","test","beta", "prod"]
| db_type | The type of db to deploy | `bool` | `null` | yes | ["mysql", "postgres"]
| disk_size | DB root volume size | `map(string)` | `{dev = "small",test = "medium",beta = "medium",prod = "large"}` | yes | small, medium, large
| instance_type | Ec2 instance type | `map(string)` | `{dev = "t3.micro",test = "t3.micro",beta = "t3.medium",prod = "t3.large"}` | yes | t3.micro,t3.medium,t3.large
| ami_id | Specific AMI id if needed | `any` | `""` | no | ami-*

## Outputs

| Name | Description |
|------|-------------|
| instance_tags | The tags from the created instance(s) |

## Folder Structure

```hcl
terraform
 ┣ modules
 ┃ ┣ aws-ec2-db
 ┃ ┃ ┣ mysql
 ┃ ┃ ┃ ┗ cloud-init.sh
 ┃ ┃ ┣ postgres
 ┃ ┃ ┃ ┗ cloud-init.sh
 ┃ ┃ ┣ main.tf
 ┃ ┃ ┣ outputs.tf
 ┃ ┃ ┗ variables.tf
 ┃ ┗ aws-vpc-clz
 ┃ ┃ ┣ main.tf
 ┃ ┃ ┣ outputs.tf
 ┃ ┃ ┗ variables.tf
 ┣ README.md
 ┣ main.tf
 ┣ outputs.tf
 ┗ variables.tf
 ```
