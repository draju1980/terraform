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