# From personal

provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "/root/.aws/credentials"
  profile = "default"
}

module "vpc" {
  #source = "../modules/vpc"
  source = "modules/vpc"

  name = "stage-vpc"
  cidr = local.cidr_vpc
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  enable_dns_hostnames = "true" #gives you an internal host name
  enable_dns_support = "true" #gives you an internal domain name
  enable_nat_gateway = "true"
  nat_instance_type = "${var.ec2_instance_type}"
  nat_key_name = "${var.inst_key_name}"
  azs      = local.availability_zones

  tags = {
    "Terraform" = "true"
    "Environment" = "stage"
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "sg_web" {
  name        = "sg_webserver"
  description = "Used in the web server"
  vpc_id      = "${module.vpc.vpc_id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Ping ec2 instances
  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_web"
  }
}

resource "aws_instance" "Centos7" {
  ami           = "ami-02eac2c0129f6376b" # uese name: centos
  instance_type = "${var.ec2_instance_type}"
  key_name = "${var.inst_key_name}"
  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.sg_web.id}"]
  subnet_id = "${module.vpc.public_subnets[0][0]}"
  associate_public_ip_address = true

  root_block_device {
    volume_size = "10"
    volume_type = "gp2"
    delete_on_termination = true
  }

#  ebs_block_device {
#    device_name = "/dev/xvdb"
#    volume_size = "5"
#    volume_type = "gp2"
#    delete_on_termination = true
#  }

  tags = {
    Name = "Webserver"
  }
}

resource "aws_instance" "DB" {
  ami           = "ami-02eac2c0129f6376b" # uese name: centos
  instance_type = "${var.ec2_instance_type}"
  key_name = "${var.inst_key_name}"
  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.sg_web.id}"]
  subnet_id = "${module.vpc.private_subnets[0][0]}"
  associate_public_ip_address = true

  root_block_device {
    volume_size = "10"
    volume_type = "gp2"
    delete_on_termination = true
  }

#  ebs_block_device {
#    device_name = "/dev/xvdb"
#    volume_size = "5"
#    volume_type = "gp2"
#    delete_on_termination = true
#  }

  tags = {
    Name = "DBserver"
  }
}