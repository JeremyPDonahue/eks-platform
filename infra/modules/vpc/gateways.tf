resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-igw"
  })
}

# NAT GATEWAY CONFIGURATION
resource "aws_eip" "eip" {
  count  = 3
  domain = "vpc"

}

resource "aws_nat_gateway" "nat" {
  vpc_id = aws_vpc.this.id

  count         = 3
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name      = "${var.cluster_name}-${subnet_id}-nat"
    ManagedBy = "terraform"
  }

}