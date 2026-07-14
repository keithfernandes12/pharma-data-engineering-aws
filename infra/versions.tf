# Terraform + provider version pins. Keeping these explicit makes the project
# reproducible: anyone running `terraform init` gets the same tooling.

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # Credentials come from the AWS CLI profile configured via `aws configure`
  # (the pharma-de-admin IAM user). Nothing secret is stored in this repo.

  default_tags {
    tags = {
      Project   = "pharma-data-engineering-aws"
      ManagedBy = "terraform"
    }
  }
}
