variable "aws_region" {
  description = "AWS Region"
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "Main VPC CIDR Block"
}

variable "availability_zones" {
  type        = list
  description = "AWS Region Availability Zones"
}
