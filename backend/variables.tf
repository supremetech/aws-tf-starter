variable "allowed_account_ids" {
  type    = list(string)
  default = []
}

variable "region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}
