# Requirements Specification

## Overview
The solution will be a website allowing a photographer to publish images to clients and will be hosted in AWS.

## Details

Each client project will be assigned a unique ID. Assets related to the project will be stored in an S3 bucket in a folder named with the unique ID.

The S3 bucket will be mounted to a Linux based webserver using a FUSE filesystem.

User access management for the site will be via an Amazon RDS instance.  This DB will contain user information, project folders to which the user has access and details of which specific assets the client can download.

By default the web server will allow users to view scaled and watermarked copies of all assets within a project folder, but will allow download of original assets where appropriate.

## User Access
User access to this site will be via HTTPS over the Internet.

## Photographer Access
The photographer will use an administrative login to the web server to upload assets and modify user permissions.  This will be done over a HTTPS connection over the Internet

## Support Access
Support engineers will require SSH access to the Web server.  This will occur over the Internet.

## Network Configurations

Both DB and webservers will be deployed into a VPC.  This VPC will have both public and private subnets.

## Security Configurations
Both the RDS instance and the EC2 instance running the webserver will be in the same VPC.  A security group will be created for the DB instances and another for the webserver instances.

The security group for the DB will allow only ICMP and TCP connections to the DB port from the security group for the webservers.

The security group for the webservers will allow SSH and HTTPS access to those servers.

## Fault Tolerance

The website is able to tolerate short, infrequent outages for situations such as RDS failure.  Longer outages potentially caused by a region failure will be managed with client communications.

2x Webserver EC2 instances will be deployed into different AZs within the ap-southeast-2 region.  The HTTPS connections to these servers will be balanced by the Elastic Load Balancer service.

The RDS instance will be configured as Multi-AZ to support replication and automatic failover to a replica.