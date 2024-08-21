#terraform/modules/vpc_private/main.tf
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway = false

  # necessary for load balancer controller to auto discover subnets
  # See https://repost.aws/knowledge-center/eks-vpc-subnet-discovery
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = var.tags
}

module "vpc_endpoints_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "${var.vpc_name}-vpc-endpoints"
  description = "Security group for VPC endpoint access"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      description = "VPC CIDR HTTPS"
      cidr_blocks = join(",", module.vpc.private_subnets_cidr_blocks)
    },
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      description = "All egress HTTPS"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = var.tags
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.9.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc_endpoints_sg.security_group_id]

  endpoints = merge({
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags = {
        Name = "${var.vpc_name}-s3"
      }
    }
    },
    { for service in toset(["autoscaling", "ecr.api", "ecr.dkr", "ec2", "ec2messages", "eks", "elasticloadbalancing", "sts", "kms", "logs", "ssm", "ssmmessages", "codecommit", "git-codecommit", "elasticfilesystem"]) :
      replace(service, ".", "_") =>
      {
        service             = service
        subnet_ids          = module.vpc.private_subnets
        private_dns_enabled = true
        tags                = { Name = "${var.vpc_name}-${service}" }
      }
  })

  tags = var.tags
}

module "global_constants" {
  source = "../global_constants"
}

resource "aws_vpc_peering_connection" "network" {
  peer_owner_id = module.global_constants.network_account_id
  peer_vpc_id   = module.global_constants.network_vpc_id
  vpc_id        = module.vpc.vpc_id
  tags          = var.tags
}

resource "aws_route" "route1" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = module.global_constants.network_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.network.id
}

resource "aws_route" "route2" {
  route_table_id            = module.vpc.private_route_table_ids[1]
  destination_cidr_block    = module.global_constants.network_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.network.id
}

module "bastion_host" {
  create_module = var.create_bastion
  source        = "../bastion_host"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.private_subnets[0]
  instance_type = var.bastion_instance_type
  ssh_key_name  = var.bastion_ssh_key_name
}