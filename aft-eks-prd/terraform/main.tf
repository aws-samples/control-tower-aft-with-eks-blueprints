################################################################################
# Providers
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
# EKS Cluster
################################################################################

module "eks" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=2cb1fac31b0fc2dd6a236b0c0678df75819c5a3b"

  cluster_name                   = local.name
  cluster_version                = "1.28"
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  manage_aws_auth_configmap = true
  aws_auth_roles = flatten([
    module.eks_blueprints_admin_team.aws_auth_configmap_role
  ])

  tags = local.tags
}


################################################################################
# EKS Blueprints Teams
################################################################################

module "eks_blueprints_admin_team" {
  source = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints-teams.git?ref=e039ac2fbcc25f8990965cc298f97208e573e74c"

  name = "admin-team"

  # Enables elevated, admin privileges for this team
  enable_admin = true
  users        = [data.aws_ssm_parameter.admin_team_arn.value]
  cluster_arn  = module.eks.cluster_arn

  tags = local.tags
}

################################################################################
# EKS Blueprints Addons
################################################################################

module "eks_blueprints_addons" {
  source = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints-addons.git?ref=c9690d68aabb0efcd9c2c2fd1f29c077d003a3d2"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_aws_load_balancer_controller = true
  enable_kube_prometheus_stack        = true
  enable_metrics_server               = true
  enable_cert_manager                 = true

  tags = local.tags

}

################################################################################
# Supporting Resources 
################################################################################

module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=acadfc42ba1ec23404eec03b69603a2cc52679b1"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}
