############################################
#    VPC
############################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "${var.project_prefix}-vpc"
  cidr = "10.1.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24"]

  enable_nat_gateway = true

  tags = {
    Name        = "${var.project_prefix}-vpc"
    Environment = "dev"
    Terraform   = "true"
  }
}

############################################
#    EC2
############################################

# EC2 Instance in Public Subnet using the ec2-instance module
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  depends_on = [ module.ec2_security_group ]

  for_each = var.ec2_instances

  name          = each.key
  instance_type = "t2.micro"
  key_name      = "vockey"
  subnet_id     = element(module.vpc.public_subnets, index(keys(var.ec2_instances), each.key))

  associate_public_ip_address = true

  user_data = each.value.user_data

  vpc_security_group_ids = [module.ec2_security_group.security_group_id]
  tags = {
    Name        = "${var.project_prefix}-${each.key}"
    Environment = "dev"
    Terraform   = "true"
  }
}

# Locals to hold the public and private IPs of all EC2 instances
locals {
  ec2_public_ips = {
    for instance_key, instance in module.ec2_instance :
    instance_key => instance.public_ip
  }

  ec2_private_ips = {
    for instance_key, instance in module.ec2_instance :
    instance_key => instance.private_ip
  }

  domain_name = "public_domain_or_public_ip" # need to take from the alb after created
}

# EC2 Instance for monitoring
module "ec2_instance_monitor" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  depends_on = [ module.ec2_instance ]

  name          = "ron-proj-ec2-instance-monitoring"
  instance_type = "t2.micro"
  key_name      = "vockey"
  subnet_id     = element(module.vpc.public_subnets, 0)

  associate_public_ip_address = true

  user_data = <<-EOF
        #!/bin/bash
        echo "${join("\n", values(local.ec2_private_ips))}" > /etc/mon_target_inst_ip
        echo "${local.domain_name}" > /etc/domain_name
        ${var.ec2_monitoring_user_data}
        EOF

  vpc_security_group_ids = [module.ec2_security_group.security_group_id]
  tags = {
    Name        = "${var.project_prefix}-ec2-instance-monitoring"
    Environment = "dev"
    Terraform   = "true"
  }
}


# Security Group for EC2 instance
module "ec2_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  depends_on = [ module.vpc ]

  name        = "${var.project_prefix}-public-ec2-sg"
  description = "Security group for public EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      description = "Allow SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow grafana"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow prometheus"
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow node-exporter"
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      description = "Allow HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name        = "${var.project_prefix}-public-ec2-sg"
    Environment = "dev"
    Terraform   = "true"
  }
}