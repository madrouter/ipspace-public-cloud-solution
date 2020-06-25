# Configure AWS Provider
provider "aws" {
	  version = "~> 2.0"
	  region = "ap-southeast-2"
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

# Create a new VPC
resource "aws_vpc" "ipspace_vpc" {
	cidr_block = "10.17.0.0/16"
	assign_generated_ipv6_cidr_block = true
	tags = {
		Name = "ipspace_vpc"
	}
}

# Create a public subnet - assign public IP by default
resource "aws_subnet" "public_subnet" {
	vpc_id = aws_vpc.ipspace_vpc.id
#	cidr_block = "10.17.1.0/24"
	cidr_block = "${cidrsubnet(aws_vpc.ipspace_vpc.cidr_block,8,1)}"
	ipv6_cidr_block = "${cidrsubnet(aws_vpc.ipspace_vpc.ipv6_cidr_block,8,1)}"
	map_public_ip_on_launch = true
	assign_ipv6_address_on_creation = true

	tags = {
		Name = "IPSpace_Public_Subnet"
	}
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
	vpc_id = aws_vpc.ipspace_vpc.id
#	cidr_block = "10.17.2.0/24"
	cidr_block = "${cidrsubnet(aws_vpc.ipspace_vpc.cidr_block,8,2)}"
	ipv6_cidr_block = "${cidrsubnet(aws_vpc.ipspace_vpc.ipv6_cidr_block,8,2)}"
	assign_ipv6_address_on_creation = true

	tags = {
		Name = "IPSpace_Private_Subnet"
	}
}

# Create an Internet Gateway
resource "aws_internet_gateway" "ipspace_gw" {
	vpc_id = aws_vpc.ipspace_vpc.id

	tags = {
		Name = "ipspace_gw"
	}
}

# Create a route-table
resource "aws_route_table" "route_table" {
	vpc_id = aws_vpc.ipspace_vpc.id
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.ipspace_gw.id
	}

	route {
		ipv6_cidr_block = "::/0"
		gateway_id = aws_internet_gateway.ipspace_gw.id
	}

	tags = {
		Name = "Default_Route"
	}
}

# Associate the route table with the subnet
resource "aws_route_table_association" "public_rt" {
	route_table_id = aws_route_table.route_table.id
	subnet_id = aws_subnet.public_subnet.id
}

# Find the default SG for the VPC
data "aws_security_group" "default_sg" {
	vpc_id = aws_vpc.ipspace_vpc.id
	name = "default"
}

resource "aws_security_group_rule" "allow_http" {
	description = "Allow inbound HTTP"
	security_group_id = data.aws_security_group.default_sg.id

	type = "ingress"
	from_port = 80
	to_port = 80
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
	ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group_rule" "allow_https" {
	description = "Allow inbound HTTPS"
	security_group_id = data.aws_security_group.default_sg.id

	type = "ingress"
	from_port = 443
	to_port = 443
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
	ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group_rule" "allow_ssh" {
	description = "Allow inbound SSH"
	security_group_id = data.aws_security_group.default_sg.id

	type = "ingress"
	from_port = 22
	to_port = 22
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
	ipv6_cidr_blocks = ["::/0"]
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
	subnet_id = aws_subnet.public_subnet.id
	iam_instance_profile = aws_iam_instance_profile.s3mountrole_instance_profile.name


	tags = {
		Name = "Web_Server"
		Web_Server = "True"
	}
}

resource "aws_instance" "jump" {
	ami = data.aws_ami.ubuntu.id
	instance_type = "t2.micro"
	key_name = "AWS_SSH_Keypair"
	subnet_id = aws_subnet.public_subnet.id

	tags = {
		Name = "Jump_Host"
	}
}

resource "aws_instance" "backend" {
	ami = data.aws_ami.ubuntu.id
	instance_type = "t2.micro"
	key_name = "AWS_SSH_Keypair"
	subnet_id = aws_subnet.private_subnet.id

	tags = {
		Name = "Backend_Server"
	}
}

#resource "aws_eip" "web_eip" {
#	instance = aws_instance.web.id
#	vpc = true
#}

