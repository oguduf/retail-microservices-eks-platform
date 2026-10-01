output "vpc_id" {
  description = "ID of the retail EKS VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets."
  value       = values(aws_subnet.public)[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets."
  value       = values(aws_subnet.private)[*].id
}

output "nat_gateway_id" {
  description = "ID of the development NAT gateway."
  value       = aws_nat_gateway.main.id
}