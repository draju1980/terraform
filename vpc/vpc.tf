provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}



// Create a new VPC
resource "aws_vpc" "demo-vpc" {
  cidr_block = "10.10.0.0/16"
    
  tags = {
    Name = "demo-vpc"
  } 
}



// Create a new subnet
resource "aws_subnet" "demo-subnet" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "demo-subnet"
  } 
}



// Create a new internet gateway
resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "demo-internet_gateway"
  } 
}



// Create a new route table
resource "aws_route_table" "demo-rt" {
  vpc_id = aws_vpc.demo-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id 
  }

  tags = {
    Name = "demo-route_table"
  }
}



// Associate the route table with the subnet
resource "aws_route_table_association" "demo-rt-assoc" {
  subnet_id      = aws_subnet.demo-subnet.id
  route_table_id = aws_route_table.demo-rt.id
}



// Create a new security group
resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  vpc_id      = aws_vpc.demo-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
    Name = "demo-security_group"
  }
}




// Create a new EC2 instance
resource "aws_instance" "demo-node" {
  ami                    = "ami-0694d931cee176e7d"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.demo-subnet.id
  security_groups        = [aws_security_group.demo-sg.id]
  associate_public_ip_address = true  


    user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              sudo usermod -aG docker ubuntu
              docker run -d -p 8080:8080 ghcr.io/draju1980/gohelloworld:main
              EOF
    tags = {
      Name = "demo_node"
  }
}
