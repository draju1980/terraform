output "public_ip" {
    description = "Public IP address of our demo node"
  value = aws_instance.demo-node.public_ip
}
output "private_ip" {
    description = "Private IP address of our demo node"
  value = aws_instance.demo-node.private_ip
}
