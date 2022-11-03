module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "~> 3.13.0"
  name                   = local.name_prefix
  cidr                   = var.vpc.cidr_block
  azs                    = var.vpc.availability_zones
  public_subnets         = var.vpc.public_subnets
  private_subnets        = var.vpc.private_subnets
  enable_nat_gateway     = var.environment == "prod"
  single_nat_gateway     = var.environment == "dev"
  one_nat_gateway_per_az = var.vpc.one_nat_per_az
  tags                   = local.common_tags
}

module "nat_instance" {
  count  = var.environment == "dev" && length(var.vpc.availability_zones) >= 1 ? (!var.vpc.one_nat_per_az ? 1 : length(var.vpc.availability_zones)) : 0
  source = "./modules/nat_instance"

  name                    = "${local.name_prefix}-nat-instance"
  vpc_id                  = module.vpc.vpc_id
  public_subnet           = !var.vpc.one_nat_per_az ? module.vpc.public_subnets[0] : module.vpc.public_subnets[count.index]
  private_route_table_ids = !var.vpc.one_nat_per_az ? module.vpc.private_route_table_ids : ["${module.vpc.private_route_table_ids[count.index]}"]
  availability_zone       = !var.vpc.one_nat_per_az ? module.vpc.azs[0] : module.vpc.azs[count.index]
  security_group_id       = aws_security_group.nat_instance.id
  key_name                = local.ssh_key_name
  use_spot_instance       = true

  tags = local.common_tags

}

resource "aws_eip" "eip_nat_instance" {
  count             = var.environment == "dev" && length(var.vpc.availability_zones) >= 1 ? (!var.vpc.one_nat_per_az ? 1 : length(var.vpc.availability_zones)) : 0
  network_interface = !var.vpc.one_nat_per_az ? module.nat_instance[0].eni_id : module.nat_instance[count.index].eni_id

  tags = merge(
    {
      Name = "${local.name_prefix}-eip-nat"
    }, local.common_tags
  )
}

###############################
# NAT Instance Security Group #
###############################
resource "aws_security_group" "nat_instance" {
  name_prefix = "${local.name_prefix}-nat-instance-sg"
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
