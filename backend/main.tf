terraform {
  required_version = "1.2.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.24.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

provider "aws" {
  allowed_account_ids = var.allowed_account_ids
  region              = var.region
}

data "aws_caller_identity" "current" {}

locals {
  name       = "${var.project_name}-${var.environment}"
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "${local.name}-tfstate-${var.region}-${local.account_id}"
}

resource "aws_s3_bucket_acl" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tfstate" {
  name         = "${local.name}-tfstate"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "local_file" "config" {
  filename        = "../config/backend.tfvars.${var.environment}"
  content         = <<EOT
region = "${var.region}"
bucket = "${aws_s3_bucket.tfstate.id}"
key = "terraform.tfstate"
dynamodb_table = "${aws_dynamodb_table.tfstate.name}"
  EOT
  file_permission = "0644"
}
