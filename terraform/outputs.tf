output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of public subnet"
  value       = aws_subnet.public.id
}

output "internet_gateway_id" {
  description = "ID of internet gateway"
  value       = aws_internet_gateway.igw.id
}

output "ec2_public_ip" {
  description = "Public IP of k3s EC2 instance"
  value       = aws_instance.k3s_node.public_ip
}

output "rds_endpoint" {
  description = "RDS connection endpoint"
  value       = aws_db_instance.app_db.endpoint
}
