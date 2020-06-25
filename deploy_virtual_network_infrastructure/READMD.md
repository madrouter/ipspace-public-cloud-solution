# Automated Server Deploy and Config
## Objective
The objective of this code is to deploy an Ubuntu Linux/Apache based web server into AWS and have it configured to serve static content held on an S3 bucket.
## Solution Overview
The solution used makes use of both Terraform and Ansible.

Terraform is used to configure the AWS infrastructure to the point where the base server will fire up.  After that, Ansible takes over to install Apache, mount the S3 bucket and configure the server.
## Solution Detail
### Assumptions
 - There is a pre-existing VPC with a Name tag of Some VPC
 - There is a pre-existing subnet in the VPC with a Name tag of Ansible_Subnet
 
###Terraform
Terraform will perform the following:
 - Find the VPC by it's Name tag
 - Find the subnet by it's Name tag
 - Find the latest Ubuntu 18.04 AMI published by Canonical
 - Create a Security Group allowing inbound connections on TCP/80 from anywhere
 - Create an IAM Role Policy allowing an EC2 instance to perform operations on an S3 bucket
 - Create an IAM Role linking the IAM Role Policy to EC2 objects
 - Create an IAM Instance Profile allowing the Role to be linked to an instance
 - Deploy a t2.micro instance into the subnet using the located AMI, apply the required security groups and instance profile and attach a tag called Web_Server with a value of true.
 - Attach an Elastic IP to the instance.

### Ansible
At this point Ansible takes over.  The ansible master is running in the same VPC as the web server being provisioned and has an IAM role assigned allowing it to query instances to build a dynamic inventory.

Ansible performs the following tasks on all hosts:
 - Forced install of Python on all hosts

Ansible performs the following tasks on all hosts with the Web_Server tag

 - Install the latest s3fs userspace tools to allow mounting the S3 bucket
 - Copy credentials file to the target server and set permissions
 - Create a mountpoint for the bucket
 - Check to see if anything is already mounted at the mountpoint and mount the bucket if not
 - Ensure /etc/rc.local exists and ensure a line exists to remount the bucket at boot
 - Install Apache and copy configuration files to it