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
    condition     = contains(["dev", "test", "stg", "prod", "phuocpham"], var.environment)
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
  type = any
  default = {
    cidr_block         = ""
    availability_zones = []
    public_subnets     = []
    private_subnets    = []
  }
}

locals {
  profile = "${var.project_name}-${var.environment}"
}

locals {
  name = "${var.project_name}-${var.environment}"
}

locals {
  common_tags = {
    Builder     = "Terraform",
    Environment = var.environment
    Service     = "${var.project_name}-${var.environment}"
  }
}

locals {
  ssh_key_name = "${var.project_name}-${var.environment}-${var.region}-key"
}
