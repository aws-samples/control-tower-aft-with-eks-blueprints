################################################################################
# Local variables
################################################################################
locals {
  name = "amazon-eks-prod-01"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

################################################################################
# Data Sources
################################################################################
data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_roles" "platform_team" {
  name_regex  = "AWSReservedSSO_AWSPowerUserAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

data "aws_iam_roles" "developers_team" {
  name_regex  = "AWSReservedSSO_AWSReadOnlyAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

data "aws_ssm_parameter" "platform_team_arn" {
  count = var.custom_platform_team ? 1 : 0
  name = "/aft/account-request/custom-fields/platform_team_arn"
}

data "aws_ssm_parameter" "dev_team_arn" {
  count = var.custom_developers_team ? 1 : 0
  name = "/aft/account-request/custom-fields/dev_team_arn"
}
