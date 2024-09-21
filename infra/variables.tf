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
    "ron-proj-ec2-instance-1" = "web-server"
    "ron-proj-ec2-instance-2" = "db-server"
  }
}

# variable "instance_names" {
#     description = "the vpc public subnets list"
#     type = list(string)
#     default = ["ron-proj-ec2-instance-1", "ron-proj-ec2-instance-2"]
# }
