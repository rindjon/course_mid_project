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

variable "public_subnets_list" {
    description = "the vpc public subnets list"
    type = list(string)
    default = ["10.1.101.0/24", "10.1.102.0/24"]
}
