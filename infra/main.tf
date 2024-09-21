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

  # for_each = toset(var.public_subnets_list)
  for_each = var.instance_names

  name          = each.key
  instance_type = "t2.micro"
  key_name      = "vockey"
  subnet_id     = element(module.vpc.public_subnets, index(keys(var.instance_names), each.key))

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              sudo mkdir -p /var/www/html
              sudo touch /var/www/html/index.html
              INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
              INSTANCE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
              sudo echo "<h1>EC2 instance $INSTANCE_ID IP $INSTANCE_IP</h1>" > /var/www/html/index.html
              # sudo echo "<h1>EC2 instance</h1>" > /var/www/html/index.html
              EOF

  vpc_security_group_ids = [module.ec2_security_group.security_group_id]

  tags = {
    Name        = "${var.project_prefix}-public-ec2-instance"
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