variable "deploy_stages" {
  type = list(string)

  validation {
    condition = (length(["dev", "test", "beta", "prod"])==length(toset(concat(["dev", "test", "beta", "prod"],var.deploy_stages))))
    error_message = "Valid values for db_type are: mysql or postgres."
 }
}

variable "db_type" {
  type = list(string)

  validation {
    condition = (length(["mysql", "postgres"])==length(toset(concat(["mysql", "postgres"],var.db_type))))
    error_message = "Valid values for db_type are: mysql or postgres."
 }
}

variable "disk_size" {
  type = map(string)

  default = {
    dev = "small"
    test = "medium"
    beta = "medium"
    prod = "large"
  }
}

variable "instance_type" {
  type = map(string)

  default = {
    dev = "t3.micro"
    test = "t3.micro"
    beta = "t3.medium"
    prod = "t3.large"
  }
}

variable "ami_id" {
  type        = string
  description = "[Optional] The id of the machine image (AMI) to use for the server."
  default     = ""
}