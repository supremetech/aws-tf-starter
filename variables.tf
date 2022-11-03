variable "project_name" {
  type = string
  validation {
    condition     = var.project_name != ""
    error_message = "The project name must be not empty."
  }
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "test", "stg", "prod"], var.environment)
    error_message = "The environment must be dev, test, stg or prod."
  }
}

variable "allowed_account_ids" {
  type    = list(string)
  default = []
}

variable "region" {
  type = string
}

variable "allowed_ip_ranges" {
  type    = list(string)
  default = []
}

variable "vpc" {
  default = {
    cidr_block      = ""
    available_zones = []
    public_subnets  = []
    private_subnets = []
  }
}

locals {
  description = "AWS account profile name"
  profile     = "${var.project_name}-${var.environment}"
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

locals {
  common_tags = {
    Builder     = "Terraform",
    Environment = "${var.environment}"
    Name        = "${var.project_name}-${var.environment}"
  }
}

locals {
  ssh_key_name = "${var.project_name}-${var.environment}-${var.aws_region}-key"
}
