terraform {
    backend "s3" {
        bucket = "ron-proj-s3-bucket"
        key = "present/infra/terraform.tfstate"
        region = "us-east-1"
    }
}
# remindr - do not use vars in backend as it gives errors