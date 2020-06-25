# Deploy IPv6
## Objective
Convert the solution from the previous exercise to IPv4/IPv6 dual-stack.

## Solution Overview
The solution uses the same steps as previously detailed, however the VPC, subnets, route-tables and SGs are all configured for IPv6

## Solution Detail
 
### Terraform
Terraform configuration has been modified to:

 - Get an AWS provided /56 address assigned to the VPC
 - Assign /64 blocks to each subnet using the cidrsubnet function to calculate it
 - Add an IPv6 default route to the route-table via the Internet GW for the public subnet
 - Add the ::/0 CIDR block as allowed sources for TCP 22, 80 and 443 in the default security group.

### Ansible
Ansible operations are performed over IPv4 and are unchanged from the previous deployment.

The ec2.py script being used to generate the dynamic inventory does not appear to support IPv6 addressing in any way.