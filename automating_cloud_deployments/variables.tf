variable "vpc_name" {
	type = string
	default = "ipspace_homework_vpc"
}

variable "vpc_name_tag" {
	type = string
	value = ${var.vpc_name}
}