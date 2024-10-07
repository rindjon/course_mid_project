variable "AWS_REGION" {
    description = "the aws region that we work on"
    type = string
    default = "us-east-1"
}

variable "s3_bucket_name" {
    description = "the s3 bucket name for the backend"
    type = string
    default = "ron-proj-s3-bucket"
}

variable "project_prefix" {
    description = "the project prefix for naming convnetions"
    type = string
    default = "ron-proj"
}

variable "vpc_name" {
    description = "the vpc name that we create"
    type = string
    default = "ron-proj-vpc"
}

variable "instance_names" {
  description = "Map of instance names"
  type        = map(string)
  default = {
    "ron-proj-ec2-instance-1" = "web-server-1"
    "ron-proj-ec2-instance-2" = "web-server-2"
  }
}

variable "ec2_instances" {
  type = map(object({
    user_data = string
  }))
  default = {
    "ron-proj-ec2-instance-1" = {
      user_data = <<-EOF
        #!/bin/bash
        sudo yum update -y
        sudo yum install -y httpd
        sudo yum install -y docker
        sudo service docker start
        sudo chkconfig docker on
        sudo systemctl start httpd
        sudo systemctl enable httpd
        sudo mkdir -p /var/www/html
        sudo touch /var/www/html/index.html
        INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
        INSTANCE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
        sudo echo "<h1>EC2 instance $INSTANCE_ID IP $INSTANCE_IP</h1>" > /var/www/html/index.html
        sudo docker pull prom/node-exporter
        sudo docker run -d --name=node-exporter -p 9100:9100 prom/node-exporter
        EOF
    }
    "ron-proj-ec2-instance-2" = {
      user_data = <<-EOF
        #!/bin/bash
        sudo yum update -y
        sudo yum install -y httpd
        sudo yum install -y docker
        sudo service docker start
        sudo chkconfig docker on
        sudo systemctl start httpd
        sudo systemctl enable httpd
        sudo mkdir -p /var/www/html
        sudo touch /var/www/html/index.html
        INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
        INSTANCE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
        sudo echo "<h1>EC2 instance $INSTANCE_ID IP $INSTANCE_IP</h1>" > /var/www/html/index.html
        sudo docker pull prom/node-exporter
        sudo docker run -d --name=node-exporter -p 9100:9100 prom/node-exporter
        EOF
    }
  }
}
variable "ec2_monitoring_user_data" {
    description = "the user data of the monitoring instance"
    type = string
    default = <<-EOF
        sudo yum update -y
        sudo yum install -y git
        sudo yum install -y docker
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        sudo usermod -a -G docker ec2-user
        sudo service docker start
        sudo chkconfig docker on
        sudo git clone https://github.com/rindjon/sys_monitoring.git /home/ec2-user/sys_monitoring
        cd /home/ec2-user/sys_monitoring
        sudo chmod +x ./replace_domain.sh
        sudo chmod +x ./prometheus/adjust_mon_targets.sh
        sudo ./replace_domain.sh
        sudo ./prometheus/adjust_mon_targets.sh
        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
        sudo docker-compose up -d
        EOF
}

  
