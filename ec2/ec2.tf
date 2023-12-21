provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

resource "aws_instance" "example" {
  ami                    = "ami-0694d931cee176e7d"
  instance_type          = "t2.micro"
}

