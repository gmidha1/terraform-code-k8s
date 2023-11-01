


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.0"
    }
    rhcs = {
      version = ">= 1.4.0"
      source  = "terraform-redhat/rhcs"
    }
  }

  backend "s3" {
    bucket = "tf-bucket-rosa-aug22"
    key    = "infra"
    region = "us-east-2"
  }

}

provider "aws" {
  region = "us-east-2"
}

provider "rhcs" {
  token = var.token
  url   = var.url
}

data "rhcs_policies" "all_policies" {}

data "rhcs_versions" "all" {}

module "create_account_roles" {
  source  = "terraform-redhat/rosa-sts/aws"
  version = "0.0.15"

  create_operator_roles = false
  create_oidc_provider  = false
  create_account_roles  = true

  account_role_prefix    = var.account_role_prefix
  ocm_environment        = var.ocm_environment
  rosa_openshift_version = var.openshift_version
  account_role_policies  = data.rhcs_policies.all_policies.account_role_policies
  operator_role_policies = data.rhcs_policies.all_policies.operator_role_policies
  all_versions           = data.rhcs_versions.all
  path                   = var.path
  tags                   = var.tags
}

output "account_role_prefix" {
  value = module.create_account_roles.account_role_prefix
}