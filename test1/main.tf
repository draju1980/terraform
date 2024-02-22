# Added aws as provider
provider "aws" {
    profile = "default"
    region  = "eu-west-1"
}

# Create a new VPC
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = "test_vpc"
    }
}

# Create a new frontend subnet
resource "aws_subnet" "frontend" {
    vpc_id     = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "eu-west-1a"
    tags = {
        Name = "frontend_subnet"
    }
}

# Create a new backend subnet
resource "aws_subnet" "backend" {
    vpc_id     = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "eu-west-1b"
    tags = {
        Name = "backend_subnet"
    }
}

# Create a new internet gateway
# Reference https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    depends_on = [ aws_subnet.backend, aws_subnet.frontend]
    tags = {
        Name = "internet_gateway"
    }
}

# Create a new route table
# Reference https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "main" {
    vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
    tags = {
        Name = "route_table"
    }
}

# Associate the route table with vpc
# Reference https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/main_route_table_association
resource "aws_main_route_table_association" "a" {
    vpc_id         = aws_vpc.main.id
    route_table_id = aws_route_table.main.id
}

# Create a new database instance
# Reference https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_db_instance" "default" {
    allocated_storage    = 10
    db_name              = "mydb"
    engine               = "mysql"
    engine_version       = "5.7"
    instance_class       = "db.t3.micro"
    username             = "foo"
    password             = "foobarbaz"
    parameter_group_name = "default.mysql5.7"
    vpc_security_group_ids = [aws_security_group.instance.id]
    db_subnet_group_name = aws_db_subnet_group.default.name
    publicly_accessible = true
    skip_final_snapshot = true
    tags = {
        Name = "My DB Instance"
    }
}

# Create a new database subnet group
# Reference https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
resource "aws_db_subnet_group" "default" {
    name       = "main"
    subnet_ids = [aws_subnet.backend.id, aws_subnet.frontend.id]

    tags = {
        Name = "My DB subnet group"
    }
}

# Create a new security group
# Reference https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "instance" {
    name = "terraform-example-instance"
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "My security group"
    }
}

# Create a new EKS cluster
# Reference https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
resource "aws_eks_cluster" "example" {
    name     = "example"
    role_arn = aws_iam_role.example.arn

  vpc_config {
    subnet_ids = [aws_subnet.frontend.id, aws_subnet.backend.id]
  }

    depends_on = [
        aws_iam_role_policy_attachment.example_eks,
        aws_iam_role_policy_attachment.example_eks_cni,
  ]
  tags = {
    Name = "My EKS cluster"
  }
}
# Create a new IAM role for the EKS cluster
# Reference https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "example" {
    name = "example"

    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach the AmazonEKSClusterPolicy to the role
# Reference https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "example_eks" {
    role       = aws_iam_role.example.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Attach AmazonEKS_CNI_Policy to the role
# Reference https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "example_eks_cni" {
    role       = aws_iam_role.example.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Create a new IAM role policy for RDS access
# Reference https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_role_policy" "example" {
    name = "example"
    role = aws_iam_role.example.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "rds:*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_db_instance.default.arn}"
    }
  ]
}
EOF
}