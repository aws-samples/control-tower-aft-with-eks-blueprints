################################################################################
# EKS Blueprints Teams
################################################################################

module "eks_blueprints_admin_team" {
  source  = "aws-ia/eks-blueprints-teams/aws"
  version = "~> 1.0"

  name = "admin-team"

  # Enables elevated, admin privileges for this team
  enable_admin = true
  users        = [data.aws_ssm_parameter.admin_team_arn.value]
  cluster_arn  = module.eks.cluster_arn

  tags = local.tags
}
