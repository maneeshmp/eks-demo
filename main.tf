data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  cluster_name = var.cluster_name
  tags         = merge({ "provisioner" = "TF", "Cluster" = local.cluster_name }, var.tags, )
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

#https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"

  name = var.vpc_name

  cidr = var.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = var.nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = var.dns_hostnames

  public_subnet_tags = {
    "Role" = "Public"
  }

  private_subnet_tags = {
    Role = "private"
  }
}

#https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = var.nodegroup_ami
  }
  eks_managed_node_groups = var.eks_managed_node_groups

}

data "aws_iam_policy" "ebs_csi_policy" {
  arn = var.ebs_csi_policy
}

#https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-assumable-role-with-oidc
module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.33.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = var.oidc_fully_qualified_subjects
}

resource "aws_eks_addon" "eks_addons" {
  for_each                 = { for addon in var.eks_addons : addon.name => addon }
  cluster_name             = module.eks.cluster_name
  addon_name               = each.value.name
  addon_version            = each.value.version
  service_account_role_arn = each.value.service_account_role_arn != "" ? module.irsa-ebs-csi.iam_role_arn : null
  tags                     = local.tags
}