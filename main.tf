terraform {
  required_version = "1.0.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.58.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "artifact_bucket" {
  source      = "./modules/s3"
  bucket_name = var.artifact_bucket_name
}

module "github_codestar_connection" {
  source = "./modules/codestar_connection"
}
