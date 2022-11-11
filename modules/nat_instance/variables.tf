variable "enabled" {
  description = "Enable or not costly resources"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name for all the resources as identifier"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "ID of the public subnet to place the NAT instance"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "Route tables ids for the private subnets."
  type        = list(string)
}

variable "security_group_id" {
  description = "NAT Instance security group id"
  type        = string
}

variable "availability_zones" {
  description = "Availability zone name"
  type        = list(string)
}

variable "one_nat_per_az" {
  description = "Place one NAT gateway in each availability zone"
  type        = bool
}

variable "image_id" {
  description = "AMI of the NAT instance. Default to the latest Amazon Linux 2"
  type        = string
  default     = ""
}

variable "instance_types" {
  description = "Candidates of spot instance type for the NAT instance. This is used in the mixed instances policy"
  type        = list(string)
  default     = ["t3.nano", "t3a.nano"]
}

variable "use_spot_instance" {
  description = "Whether to use spot or on-demand EC2 instance"
  type        = bool
  default     = true
}

variable "key_name" {
  description = "Name of the key pair for the NAT instance. You can set this to assign the key pair to the NAT instance"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to resources created with this module"
  type        = map(string)
  default     = {}
}

variable "user_data_write_files" {
  description = "Additional write_files section of cloud-init"
  type        = list(any)
  default     = []
}

variable "user_data_runcmd" {
  description = "Additional runcmd section of cloud-init"
  type        = list(list(string))
  default     = []
}

# locals {
#   // Merge the default tags and user-specified tags.
#   // User-specified tags take precedence over the default.
#   common_tags = merge(
#     {
#       Name = "${var.name}"
#     },
#     var.tags
#   )
# }

variable "ssm_policy_arn" {
  description = "SSM Policy to be attached to instance profile"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
