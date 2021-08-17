terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.42.0"
    }
  }

  backend "s3" {
    key = "state"
    dynamodb_table = "terraform"
  }
}

provider "aws" {
}
