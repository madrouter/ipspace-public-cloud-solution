# Configure AWS Provider
provider "aws" {
	  version = "~> 2.0"
	  region = "ap-southeast-2"
}

# Find a VPC
data "aws_vpc" "selected" {
	Name = "Some Name"
}

# Find a subnet
data "aws_subnet" "selected" {
	Name = "Ansible_Subnet"
}

# Find an AMI
data "aws_ami" "ubuntu" {
	most_recent = true

	filter {
		name = "name"
		values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
	}
	filter {
		name = "virtualization-type"
		values = ["hvm"]
	}

	owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "allow_http" {
	name = "allow_http"
	description = "Allow inbound HTTP"
	vpc_id = data.aws_vpc.selected.id

	ingress {
		description = "HTTP from Anywhere"
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "allow_http"
	}
}

resource "aws_iam_role_policy" "s3mountrole_policy" {
	name = "s3mountrole_policy"

	role = aws_iam_role.s3mountrole.id
	policy = file("s3mount_policy.json")
	
}

resource "aws_iam_role" "s3mountrole" {
	name = "s3mountrole"

	assume_role_policy = file("s3mountrole-assume-policy.json")
}

resource "aws_iam_instance_profile" "s3mountrole_instance_profile" {
	name = "s3mountrole_instance_profile"
	role = aws_iam_role.s3mountrole.name
}

resource "aws_instance" "web" {
	ami = data.aws_ami.ubuntu.id
	instance_type = "t2.micro"
	key_name = "AWS_SSH_Keypair"
	subnet_id = data.aws_subnet.selected.id
	vpc_security_group_ids = [aws_security_group.allow_http.id,"sg-0b057632ad72f1e67"]
	iam_instance_profile = aws_iam_instance_profile.s3mountrole_instance_profile.name


	tags = {
		Name = "Web_Server"
		Web_Server = "True"
	}
}

resource "aws_eip" "web_eip" {
	instance = aws_instance.web.id
	vpc = true
}

