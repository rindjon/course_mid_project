output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "azs" {
  description = "The availability zones in the region"
  value       = module.vpc.azs
}

output "private_subnets" {
  description = "The private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "The public subnets"
  value       = module.vpc.public_subnets
}

output "ec2_id" {
  description = "The ID of the EC2"
  value       = module.ec2_instance.id
}

output "ec2_ip_public" {
  description = "The ID of the EC2"
  value       = module.ec2_instance.public_ip
}

