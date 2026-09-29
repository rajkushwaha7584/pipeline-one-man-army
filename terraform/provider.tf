terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Or use "~> 5.81.0" for a specific recent version
    }
  }
}

provider "aws" {
  region = var.aws_region
}