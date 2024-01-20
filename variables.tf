
#Common variables

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region"
  type        = string
}


#VPC variables 

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "private_subnets" {
  description = "private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "public subnets"
  type        = list(string)
}

variable "nat_gateway" {
  description = "Whether to enable or disable NAT gateways"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to enable or disable Single NAT gateways"
  type        = bool
  default     = true
}

variable "dns_hostnames" {
  description = "Whether to enable dns hostname resolution"
  type        = bool
  default     = true
}

# EKS Cluster Variables 

variable "cluster_name" {
  description = "Name of the eks cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to spin up"
  type        = string
}

variable "nodegroup_ami" {
  description = "Amazon Machine images for node groups"
  type        = string
}

variable "eks_managed_node_groups" {
  description = "Manage the node groups"
  type        = map(any)
}

variable "ebs_csi_policy" {
  description = "use ebs cis policy"
  type        = string
}

#OIDC assume role 

variable "oidc_fully_qualified_subjects" {
  description = "The fully qualified OIDC subjects to be added to the role policy"
  type        = list(string)
}

#Addons 

variable "eks_addons" {
  description = "The addons to be enabled"
  type = list(object({
    name                     = string
    version                  = string
    service_account_role_arn = string
  }))
  default = []
}