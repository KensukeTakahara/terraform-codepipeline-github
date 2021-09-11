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

module "ecs" {
  source            = "./modules/ecs"
  service_name      = var.service_name
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}

module "ecr" {
  source       = "./modules/ecr"
  service_name = var.service_name
}

module "artifact_bucket" {
  source      = "./modules/s3"
  bucket_name = var.artifact_bucket_name
}

module "codestar_connection_github" {
  source = "./modules/codestar_connection"
}

module "codebuild" {
  source                 = "./modules/codebuild"
  service_name           = var.service_name
  bucket_arn             = module.artifact_bucket.arn
  ecr_arn                = module.artifact_bucket.arn
  codestar_conection_arn = module.codestar_connection_github.arn
}
