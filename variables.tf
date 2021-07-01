variable "environment" {
    type = string
    description = "Options: development, qa, staging, production"
	default = "staging"
}

variable "ec2_instance_type" {
  description = "This is a default instance type of EC2"
  default     = "t2.micro"
}

variable "inst_key_name" {
  description = "Enable ssh connection to NAT instance"
  default     = "dev_key_pair"
}

variable "cidr_ab" {
    type = map
    default = {
        development     = "172.22"
        qa              = "172.24"
        staging         = "172.26"
        production      = "172.28"
    }
}

locals {
    availability_zones = data.aws_availability_zones.available.names
	cidr_vpc = "${lookup(var.cidr_ab, var.environment)}.0.0/16"
}
/*
variable "cidr_vpc" {
    type = string
    description = "Required: The CIDR Block For The VPC."
	default = ""
}
*/
locals {
    cidr_c_private_subnets  = 1
    cidr_c_database_subnets = 11
    cidr_c_public_subnets   = 64

    max_private_subnets     = 2
    max_database_subnets    = 2
    max_public_subnets      = 2
}

data "aws_availability_zones" "available" {
    state = "available"
}

locals {
    private_subnets = [
        for az in local.availability_zones : 
            "${lookup(var.cidr_ab, var.environment)}.${local.cidr_c_private_subnets + index(local.availability_zones, az)}.0/24"
            if index(local.availability_zones, az) < local.max_private_subnets
        ]
    database_subnets = [
        for az in local.availability_zones : 
            "${lookup(var.cidr_ab, var.environment)}.${local.cidr_c_database_subnets + index(local.availability_zones, az)}.0/24"
            if index(local.availability_zones, az) < local.max_database_subnets
        ]
    public_subnets = [
        for az in local.availability_zones : 
            "${lookup(var.cidr_ab, var.environment)}.${local.cidr_c_public_subnets + index(local.availability_zones, az)}.0/24"
            if index(local.availability_zones, az) < local.max_public_subnets
        ]
}