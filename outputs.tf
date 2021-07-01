/*


output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
*/

output "public_ip" {
  value       = aws_instance.Centos7.public_ip
  description = "The public IP of the web server"
}