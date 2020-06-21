output "vpc_arn" {
	value = data.aws_vpc.selected.arn
	description = "ARN of the VPC"
}
output "vpc_id" {
	value = data.aws_vpc.selected.id
	description = "ID of the VPC"
}