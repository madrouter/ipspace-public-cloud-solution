output "vpc_arn" {
	value = aws_vpc.arn
	description = "ARN of the VPC"
}
output "vpc_id" {
	value = aws_vpc.id
	description = "ID of the VPC"
}