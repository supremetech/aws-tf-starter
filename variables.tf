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
