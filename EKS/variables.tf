variable "location" {
    default = "eu-west-1"
}

variable "os_name" {
  default = "ami-0694d931cee176e7d"
}

variable "key" {
    default = "devops"
}

variable "instance-type" {
    default = "t2.small"
}

variable "vpc-cidr" {
    default = "10.10.0.0/16"  
}

variable "subnet1-cidr" {
    default = "10.10.10.0/24"
  
}
variable "subnet2-cidr" {
    default = "10.10.20.0/24"
  
}
variable "subent1_az" {
    default =  "eu-west-1a"  
}

variable "subent2_az" {
    default =  "eu-west-1b"  
}