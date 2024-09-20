terraform {
    backend "s3" {
        bucket = "terrform-ron"
        key = "present/env/terraform.tfstate"
        region = "us-east-1"
    }
}
# remindr - do not use vars in backend as it gives errors