terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAT66DWZQY223HJ5VE"
  secret_key = "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"
}