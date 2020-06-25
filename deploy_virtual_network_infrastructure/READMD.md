# Deploy Virtual Network Infrastructure
## Objective
The objective of this code is to deploy three Ubuntu Linux VMs.  An Apache based web server configured to serve static content held on an S3 bucket, a backend server and a jumphost.

The web server and jumphost are in a public subnet and are automatically assigned public IP addresses at instance start.  The backend server is in a private subnet.

TCP ports 22,80 and 443 are open by default to all machines on either subnet.
## Solution Overview
The solution used makes use of both Terraform and Ansible.

Terraform is used to configure the AWS infrastructure to the point where the base server will fire up.  After that, Ansible takes over to install Apache, mount the S3 bucket and configure the server.
## Solution Detail
 
###Terraform
Terraform will perform the following:
 - Create a new VPC
 - Create a new public subnet
 - Create a new private subnet
 - Create a new Internet Gateway and associate it with the newly created VPC
 - Create a route-table with a default route via the Internet Gateway
 - Associate the route-table with the public subnet
 - Find the default security-group for the VPC by name
 - Add entries to the security-group allowing TCP 22, 80 and 443 inbound
 - Find the latest Ubuntu 18.04 AMI published by Canonical
 - Create an IAM Role Policy allowing an EC2 instance to perform operations on an S3 bucket
 - Create an IAM Role linking the IAM Role Policy to EC2 objects
 - Create an IAM Instance Profile allowing the Role to be linked to an instance
 - Deploy a t2.micro instance into the public subnet using the located AMI, apply the instance profile and attach a tag called Web_Server with a value of true.
 - Deploy a further two t2.micro instances, on into the public subnet and the other into the private subnet using the located AMI

### Ansible
At this point Ansible takes over.  The ansible master is running in the same AWS tenant as the new VPC and has an IAM role assigned allowing it to query instances to build a dynamic inventory.

Ansible is configured to use an SSH bastion host to reach any private IP addresses.

Ansible performs the following tasks on all hosts:
 - Forced install of Python on all hosts
     + Note that this fails for the backend host since it has no Internet connectivity and cannot access repositories
 - Hosts with public IP addresses are accessed directly over the Internet

Ansible performs the following tasks on all hosts with the Web_Server tag

 - Install the latest s3fs userspace tools to allow mounting the S3 bucket
 - Copy credentials file to the target server and set permissions
 - Create a mountpoint for the bucket
 - Check to see if anything is already mounted at the mountpoint and mount the bucket if not
 - Ensure /etc/rc.local exists and ensure a line exists to remount the bucket at boot
 - Install Apache and copy configuration files to it

### Testing
Ansible validates SSH connectivity to public facing hosts by successfully installing python.

Ansible validates Web access to the web server by downloading the default page and checking for a 200 result code.

Ansible validates SSH connectivity from the jumphost to the backend server by connecting to it via the jumphost bastion and executing raw ping commands to the jumphost and to the Google anycast DNS servers.

Ansible validates SSH connectvitiy from the jumphost to the backend server by successfully installing python on the back