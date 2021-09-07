variable "stage" {
  type        = string
  description = "some test value"
}

variable "instance_type" {
  type        = string
  description = "some test value"
}

variable "ami_id" {
  type        = string
  description = "some test value"
}

variable "db_type" {
  type = list(string)
}

variable "disk_size" {
  type        = string
  description = "some test value"
}

variable "parameter_sg_port_mysql" {
  type        = string
  default     = 3306
  description = "some test value"
}

variable "parameter_sg_port_postgres" {
  type        = string
  default     = 5432
  description = "some test value"
}

variable "parameter_default_usr_mysql" {
  type        = string
  default     = "mysql"
  description = "some test value"
}

variable "parameter_default_usr_postgres" {
  type        = string
  default     = "postgres"
  description = "some test value"
}

variable "parameter_default_db_postgres" {
  type        = string
  default     = "postgres"
  description = "some test value"
}

variable "parameter_default_db_mysql" {
  type        = string
  default     = "default"
  description = "some test value"
}

#variable "parameter_disk_size_map" {
#  type        = map(string)
#}

variable "tag_domain_name" {
  type        = string
  description = "some test value"
  default     = "test.com"
}

variable "tag_db_default_db" {
  type        = string
  description = "some test value"
  default     = "default"
}

variable "tag_db_user" {
  type        = string
  description = "some test value"
  default     = "mysql"
}