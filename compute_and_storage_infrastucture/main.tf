# Configure AWS Provider
provider "aws" {
	  version = "~> 2.0"
	  region = "ap-southeast-2"
}

# Find a VPC
data "aws_vpc" "selected" {
	id = "vpc-0637f3e7dd807f078"
}

# Find a subnet
data "aws_subnet" "selected" {
	id = "subnet-0b88c611f4314d3d5"
}

# Find an AMI
data "aws_ami" "ubuntu" {
	most_recent = true

	filter {
		name = "name"
		value = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
	}
	filter {
		name = "virtualization-type"
		values = ['hvm']
	}

	owners = ["099720109477"] # Canonical
}

# Find a KeyPair
data "aws_keypair" "selected" {
	filter {
		name = "name"
		value = "AWS_SSH_Keypair"
	}
}

resource "aws_instance" "web" {
	ami = "${data.aws_ami.ubuntu.id}"
	instance_type = "t2.micro"
	keypair = "${data.aws_keypair.selected.id}"

	tags = {
		Name = Web_Server
	}
}