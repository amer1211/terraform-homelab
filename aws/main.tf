terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-homelab-terraform-state-386381158423"
    key            = "aws/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-homelab-terraform-lock"
  }
}

provider "aws" {
  region = var.aws_region
}
