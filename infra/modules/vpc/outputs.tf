output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_id_private" {
  value = aws_subnet.private[*].id
}

output "subnet_id_public" {
  value = aws_subnet.public[*].id
}