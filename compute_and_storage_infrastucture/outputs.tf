output "vpc_arn" {
	value = aws_vpc.ipspace_homework.arn
	description = "ARN of the VPC"
}
output "vpc_id" {
	value = aws_vpc.ipspace_homework.id
	description = "ID of the VPC"
}