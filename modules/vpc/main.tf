resource "aws_vpc" "mod" {
  cidr_block           = "${var.cidr}"
  instance_tenancy     = "${var.instance_tenancy}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

#  enable_classiclink              = "${var.enable_classiclink}"
#  enable_classiclink_dns_support  = "${var.enable_classiclink_dns_support}"

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

resource "aws_subnet" "private" {
  count = "${length(var.private_subnets)}"

  vpc_id            = "${aws_vpc.mod.id}"
  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(var.tags, var.private_subnet_tags, map("Name", format("%s-subnet-private-%s", var.name, element(var.azs, count.index))))}"
}

resource "aws_subnet" "public" {
  count = "${length(var.public_subnets)}"

  vpc_id                  = "${aws_vpc.mod.id}"
  cidr_block              = "${var.public_subnets[count.index]}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags = "${merge(var.tags, var.public_subnet_tags, map("Name", format("%s-subnet-public-%s", var.name, element(var.azs, count.index))))}"
}

# It enables your vpc to connect to the internet
resource "aws_internet_gateway" "mod" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.mod.id}"

  tags = "${merge(var.tags, map("Name", format("%s-igw", var.name)))}"
}

resource "aws_route_table" "public" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id           = "${aws_vpc.mod.id}"
#  propagating_vgws = ["${var.public_propagating_vgws}"]

  tags = "${merge(var.tags, map("Name", format("%s-rt-public", var.name)))}"
}

resource "aws_route" "public_internet_gateway" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

#  route_table_id         = "${aws_route_table.public.id}"
  route_table_id         = "${aws_route_table.public[0].id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.mod[0].id}"
#  gateway_id             = "${aws_internet_gateway.mod.id}"
}

resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public[0].id}"
}

### Private routing

resource "aws_route_table" "private" {
  #count = "${length(var.azs)}"
  count = "${length(var.private_subnets) > 0 ? 1 : 0}"

  vpc_id           = "${aws_vpc.mod.id}"
#  propagating_vgws = ["${var.private_propagating_vgws}"]

  tags = "${merge(var.tags, map("Name", format("%s-rt-private-%s", var.name, element(var.azs, count.index))))}"
}

resource "aws_security_group" "nat" {
  name = "nat"
  description = "Allow nat traffic"
  vpc_id = "${aws_vpc.mod.id}"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = "${merge(var.tags, map("Name", format("%s", "sg_nat")))}"
}

resource "aws_instance" "nat" {
    ami = "${var.nat_ami}"
    instance_type = "${var.nat_instance_type}"
    key_name = "${var.nat_key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat.id}"]
    subnet_id = "${element(aws_subnet.public.*.id, 0)}"
    associate_public_ip_address = true
    source_dest_check = false

    tags = "${merge(var.tags, map("Name", format("%s", "vpc_nat")))}"
}

/*
# for nat elastic IP
resource "aws_eip" "nat" {
    instance = "${aws_instance.nat.id}"
    vpc = true
}
*/
resource "aws_route" "private_nat_gateway" {
  #count = "${var.enable_nat_gateway ? length(var.azs) : 0}"
  count = "${length(var.private_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  instance_id         = "${aws_instance.nat.id}"
  
  depends_on = [
    aws_instance.nat,
  ]
}


resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnets)}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
#  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}