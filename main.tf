terraform {
  #############################################################
  ## AFTER RUNNING TERRAFORM APPLY (WITH LOCAL BACKEND)
  ## YOU WILL UNCOMMENT THIS CODE THEN RERUN TERRAFORM INIT
  ## TO SWITCH FROM LOCAL BACKEND TO REMOTE AWS BACKEND
  #############################################################
#   backend "s3" {
#     bucket         = "terraform-tf-state-{YOUR_AWS_ACCOUNT}"
#     key            = "../terraform.tfstate"
#     region         = "eu-central-1"
#     dynamodb_table = "terraform-state-locking-{YOUR_AWS_ACCOUNT}"
#     encrypt        = true
#   }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current_region" {}


locals {
  account_id = data.aws_caller_identity.current.account_id
  raw_prefix = "landing"
  tgt_prefix = "active"
}


resource "aws_s3_bucket" "terraform_state" {
  bucket        = "terraform-tf-state-${local.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf" {
  bucket        = aws_s3_bucket.terraform_state.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking-${local.account_id}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
#
#module "emr-cluster-module" {
#  source = "./emr-cluster-setup-module"
#  bucket_name  =  "emr-course-tf-${local.account_id}"
#  raw_prefix = local.raw_prefix
#  tgt_prefix = local.tgt_prefix
#  # put missing values
#  emr_key_name = ""
#  emr_subnet_id = ""
#  eip_allocation_id = ""
#  spark_app_bucket_name = "spark-app-tf-${local.account_id}"
#  region_name = data.aws_region.current_region.name
#  account_id = local.account_id
#}

#module "step-function-module" {
#  source = "./step-function-module"
#  step_function_name = "emr-spark-step-function-tf-${local.account_id}"
#  bucket_arn = module.emr-cluster-module.bucket_arn
#  bucket_name = module.emr-cluster-module.bucket_name
#  spark_app_bucket_name = module.emr-cluster-module.spark_app_bucket_name
#  tgt_prefix = local.tgt_prefix
#  raw_prefix = local.raw_prefix
#  region_name = data.aws_region.current_region.name
#  account_id = local.account_id
#}


