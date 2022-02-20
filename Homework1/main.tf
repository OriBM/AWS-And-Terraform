locals {
  common_tags = {
    Owner   = "oribm",
    Purpose = "whiskey"
  }

}
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}


resource "aws_default_vpc" "default" {

}

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]