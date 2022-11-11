#
module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "~> 3.13.0"
  name                   = local.name
  cidr                   = var.vpc.cidr_block
  azs                    = var.vpc.availability_zones
  public_subnets         = var.vpc.public_subnets
  private_subnets        = var.vpc.private_subnets
  enable_nat_gateway     = var.vpc.enable_nat_gateway
  one_nat_gateway_per_az = var.vpc.one_nat_per_az
  tags                   = local.common_tags
}

module "nat_instance" {
  # move to module to calculate number of nat instance(s)
  source = "./modules/nat_instance"

  name                    = "${local.name}-nat-instance"
  vpc_id                  = module.vpc.vpc_id
  public_subnets          = module.vpc.public_subnets
  private_route_table_ids = module.vpc.private_route_table_ids
  availability_zones      = module.vpc.azs
  security_group_id       = aws_security_group.nat_instance.id
  key_name                = module.key_pair.key_pair_name
  use_spot_instance       = true
  one_nat_per_az          = var.vpc.one_nat_per_az

  tags = local.common_tags

}

resource "aws_eip" "eip_nat_instance" {
  count             = length(module.nat_instance.eni_ids)
  network_interface = module.nat_instance.eni_ids[count.index]

  tags = merge(
    {
      Name = "${local.name}-eip-nat"
    }, local.common_tags
  )
}

###############################
# NAT Instance Security Group #
###############################
resource "aws_security_group" "nat_instance" {
  name_prefix = "${local.name}-nat-instance-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for NAT instance"
  tags        = local.common_tags
}

resource "aws_security_group_rule" "nat_instance_egress" {
  security_group_id = aws_security_group.nat_instance.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
}

resource "aws_security_group_rule" "nat_instance_ingress_private_subnets" {
  security_group_id = aws_security_group.nat_instance.id
  type              = "ingress"
  cidr_blocks       = module.vpc.private_subnets_cidr_blocks
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
}

resource "aws_security_group_rule" "nat_instance_ingress_ssh" {
  count             = length(var.allowed_ip_ranges) > 0 ? 1 : 0
  security_group_id = aws_security_group.nat_instance.id
  type              = "ingress"
  cidr_blocks       = var.allowed_ip_ranges
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}
