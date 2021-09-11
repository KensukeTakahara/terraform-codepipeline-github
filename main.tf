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

module "network" {
  source = "./modules/network"
}

module "artifact_bucket" {
  source      = "./modules/s3"
  bucket_name = var.artifact_bucket_name
}

module "github_codestar_connection" {
  source = "./modules/codestar_connection"
}

module "example_service" {
  source            = "./modules/ecs"
  service_name      = "example"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}
