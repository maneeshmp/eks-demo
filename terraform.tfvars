region             = "us-east-2"
cluster_name       = "zenler-demo"
vpc_name           = "zenler-vpc"
vpc_cidr           = "10.0.0.0/16"
private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
nat_gateway        = true
single_nat_gateway = true
dns_hostnames      = true

#Cluster 
kubernetes_version = "1.27"
nodegroup_ami      = "AL2_x86_64"
eks_managed_node_groups = {
  one = {
    name           = "node-group-1"
    instance_types = ["t3.small"]
    min_size       = 1
    max_size       = 3
    desired_size   = 2
  }

  two = {
    name           = "node-group-2"
    instance_types = ["t3.small"]
    min_size       = 1
    max_size       = 2
    desired_size   = 1
  }
}


#https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/
ebs_csi_policy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"


#OIDC assume role 
oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]

# Add more add-ons as needed
eks_addons = [
  {
    name                     = "aws-ebs-csi-driver"
    version                  = "v1.20.0-eksbuild.1"
    service_account_role_arn = "ebs"
  }
]