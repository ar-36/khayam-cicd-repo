#terraform/dev/trends-rts/vpc/main.tf
provider "aws" {
  region = module.global_constants.region
}

module "global_constants" {
  source = "../../../modules/global_constants"
}

locals {
  env             = "dev"
  cidr            = "10.163.5.0/24"
  azs             = module.global_constants.default_azs
  peer_vpc_cidr   = "10.163.4.0/24"
  peer_vpc_id     = "vpc-0bf3215dfe321d5"
  peer_owner_id   = "123456789012"
  peer_vpc_RT     = "rts-34342542232"
}

module "vpc" {
  source               = "../../../modules/vpc_private"
  vpc_name             = "${local.env}-trends-rts-vpc"
  vpc_cidr             = local.cidr
  vpc_azs              = local.azs
  private_subnet_cidrs = ["10.163.7.0/25", "10.163.7.128/25"]
  tags                 = { env = "${local.env}" }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = module.vpc.vpc_id
  peer_vpc_id   = local.peer_vpc_id
  peer_owner_id = local.peer_owner_id
  auto_accept   = true

  tags = {
    Name = "${local.env}-to-peer-vpc"
  }
}

resource "aws_route" "to_peer_vpc" {
  count = length(module.vpc.private_route_table_ids)

  route_table_id            = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block    = local.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id

  depends_on = [aws_vpc_peering_connection.peer]
}


# Route in the peer VPC, assuming control of peer VPC
resource "aws_route" "from_peer_vpc" {
  route_table_id            = local.peer_vpc_RT 
  destination_cidr_block    = local.cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_security_group_rule" "allow_peer_traffic" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [local.peer_vpc_cidr]
  security_group_id = module.vpc.vpc_default_security_group_id
}


