# Configure AWS Provider
provider "aws" {
	  version = "~> 2.0"
	  region = "ap-southeast-2"
}

# Find a VPC
data "aws_vpc" "selected" {
	id = "vpc-0637f3e7dd807f078"
}