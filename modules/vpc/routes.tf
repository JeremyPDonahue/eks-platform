# ROUTE TABLE DEFINITION - PUBLIC
resource "aws_route_table" "route_table_public" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gateway.id
    }

    tags = {
      Name = "public-route-table"
      Cluster = var.cluster_name
      Environment = var.environment
      ManagedBy = "terraform"
    }
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.route_table_public.id
}

# ROUTE TABLE DEFINITION - PRIVATE
resource "aws_route_table" "route_table_private" {
    count = 3
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat[count.index].id
    }

    tags = {
      Name = "private-route-table"
      Cluster = var.cluster_name
      Environment = var.environment
      ManagedBy = "terraform"
    }
}


resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.route_table_private[count.index].id
}