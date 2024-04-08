################################################################################
# EKS Required Providers
################################################################################
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

################################################################################
# EKS Cluster dependencies
################################################################################
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

################################################################################
# EKS Cluster
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = local.name
  cluster_version                = "1.29"
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true
  access_entries = {
    platform-team = {
      kubernetes_groups = []
      principal_arn     = data.aws_ssm_parameter.admin_team_arn.value

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }
}
