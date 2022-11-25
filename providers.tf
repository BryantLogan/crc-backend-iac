terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {}
}

# provider "aws" {
#   region                   = "us-east-1"
#   shared_credentials_files = ["~/.aws/credentials"]
#   profile                  = "vscode"
# }