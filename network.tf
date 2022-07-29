module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "~> 3.13.0"
  name                   = local.name
  cidr                   = var.vpc.cidr_block
  azs                    = var.vpc.available_zones
  public_subnets         = var.vpc.public_subnets
  private_subnets        = var.vpc.private_subnets
  enable_nat_gateway     = var.environment == "prod"
  single_nat_gateway     = var.environment == "dev"
  one_nat_gateway_per_az = true
  tags                   = local.tags
}

# IP whitelist
module "allowed_ip_ranges" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${local.name}-ip-st"
  description = "${local.name}-ip-st"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = var.allowed_ip_ranges
  ingress_rules       = ["all-tcp"]
}

module "nat" {
  source = "int128/nat-instance/aws"

  enabled                     = var.environment != "prod"
  name                        = local.name
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
  key_name                    = module.key_pair.key_pair_key_name
}

resource "aws_eip" "nat" {
  network_interface = module.nat.eni_id
  tags = {
    Name = "${local.name}-nat"
  }
}

resource "aws_security_group_rule" "nat_ssh" {
  security_group_id = module.nat.sg_id
  type              = "ingress"
  cidr_blocks       = var.allowed_ip_ranges
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}
