# Configure AWS Provider
provider "aws" {
	  version = "~> 2.0"
	  region = "ap-southeast-2"
}

# Create a VPC
resource "aws_vpc" "${var.vpc_name}" {
	cidr_block = "192.168.0.0/16"
	tags = {
		Name = "${var.vpc_name_tag}"
	}
}