terraform {
  required_version = "1.2.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region              = var.region
  allowed_account_ids = var.allowed_account_ids
}

data "aws_caller_identity" "current" {}

locals {
  name = "${var.project_name}-${var.environment}"
  tags = {
    Name    = local.name
    Builder = "Terraform"
  }
  account_id = data.aws_caller_identity.current.account_id
}
