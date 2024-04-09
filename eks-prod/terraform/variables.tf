variable "custom_platform_team" {
    description = "Define if using a custom AWS IAM Role ARN stored in a Parameter Store for Plaform Team."
    type = bool
    default = false
}

variable "custom_developers_team" {
    description = "Define if using a custom AWS IAM Role ARN stored in a Parameter Store for Developers Team."
    type = bool
    default = false
}