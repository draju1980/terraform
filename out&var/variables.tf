variable "region" {
  default = "eu-west-1"
}

variable "ami" {
  default = "ami-0694d931cee176e7d"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "vpc_cidr_block" {
  default = "10.10.0.0/16"
}

variable "subnet_cidr_block" {
  default = "10.10.1.0/24"
}
