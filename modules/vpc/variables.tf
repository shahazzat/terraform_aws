variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  default     = ""
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC."
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC."
  default     = []
}

variable "azs" {
  description = "A list of Availability zones in the region"
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the public subnets"
  default     = {}
}

variable "map_public_ip_on_launch" {
  description = "should be false if you do not want to auto-assign public IP on launch"
  default     = true
}

variable "enable_dns_hostnames" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = false
}

variable "enable_dns_support" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = false
}

# instance_tenancy: if it is true, your ec2 will be the only instance in an AWS physical hardware. Sounds good but expensive.
variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "public_propagating_vgws" {
  description = "A list of VGWs the public route table should propagate."
  default     = []
}

variable "enable_nat_gateway" {
  description = "should be true if you want to provision NAT Gateways for each of your private networks"
  default     = false
}

/*
variable "single_nat_gateway" {
  description = "should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}
*/

variable "nat_ami" {
  description = "This is a special ami preconfigured to do NAT. user: ec2-user"
  default     = "ami-00a9d4a05375b2763"
}

variable "nat_instance_type" {
  description = "This is a default instance type of NAT"
  default     = ""
}

variable "nat_key_name" {
  description = "Enable ssh connection to NAT instance"
  default     = ""
}