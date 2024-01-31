// Associate the route table with the subnet
resource "aws_route_table_association" "demo-rt-assoc" {
  subnet_id      = aws_subnet.demo-subnet.id
  route_table_id = aws_route_table.demo-rt.id
}
