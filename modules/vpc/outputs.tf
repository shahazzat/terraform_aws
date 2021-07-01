output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}

output "public_subnets" {
  value = ["${aws_subnet.public.*.id}"]
}

output "vpc_id" {
  value = "${aws_vpc.mod.id}"
}

output "vpc_cidr_block" {
  value = "${aws_vpc.mod.cidr_block}"
}


