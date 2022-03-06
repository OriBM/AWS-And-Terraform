terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.1.0"
    }
  }
}



provider "aws" {
  profile = "oribm"
  region  = var.aws_region
  default_tags {
    tags = {
      Owner = var.owner_tag
    }
  }
}