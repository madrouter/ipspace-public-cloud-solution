# Homework for Automating Cloud Deployments

## Chosen IaC tool

I have chosen Terraform Cloud as my IAC tool for this exercise.
## Terraform Setup
Terraform Cloud has been configured with a Workspace specific to this module.  It is linked to the GitHub repo and configued with a working directory to keep the exercises separate.

AWS Credentials are stored as variables in the Workspace configuration.

## Terraform Code

The code will instantiate a simple VPC in AWS.  The "Name" tag is set as a variable and can be changed.

 