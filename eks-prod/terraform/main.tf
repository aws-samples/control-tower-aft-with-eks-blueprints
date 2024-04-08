################################################################################
# Local variables
################################################################################
locals {
  name = basename(path.cwd)

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

data "aws_ssm_parameter" "admin_team_arn" {
  name = "/aft/account-request/custom-fields/admin_team_arn"
}

data "aws_ssm_parameter" "dev_team_arn" {
  name = "/aft/account-request/custom-fields/dev_team_arn"
}
