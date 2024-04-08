################################################################################
# EKS Blueprints Teams
################################################################################
module "development_team" {
  source  = "aws-ia/eks-blueprints-teams/aws"
  version = "~> 1.1.0"

  name = "development-team"

  cluster_arn       = module.eks.cluster_arn
  oidc_provider_arn = module.eks.oidc_provider_arn

  users = [data.aws_ssm_parameter.dev_team_arn]

  labels = {
    team = "development"
  }

  annotations = {
    team = "development"
  }

  namespaces = {
    default = {
      create = false
    }

    app01 = {
      labels = {
        projectName = "app01",
      }
    }
  }

  tags = {
    Environment = "PRODUCTION"
  }
}
