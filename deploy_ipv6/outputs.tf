output "instance_arn" {
	value = aws_instance.web.arn
	description = "ARN of the VPC"
}
output "instance_id" {
	value = aws_instance.web.id
	description = "ID of the VPC"
}