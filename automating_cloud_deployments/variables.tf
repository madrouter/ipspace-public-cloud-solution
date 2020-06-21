variable "vpc_name" {
	type = string
	default = "ipspace_homework_vpc"
}

variable "vpc_tags" {
	type = list(string)
	value = ["tag1"]
}