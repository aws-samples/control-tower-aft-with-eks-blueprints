data "aws_availability_zones" "available" {}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "admin_team_arn" {
  name = "/aft/account-request/custom-fields/admin_team_arn"
}
