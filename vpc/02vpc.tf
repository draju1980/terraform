// Create a new VPC
resource "aws_vpc" "demo-vpc" {
  cidr_block = "10.10.0.0/16"
    
  tags = {
    Name = "demo-vpc"
  } 
}