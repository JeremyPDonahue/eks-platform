# INTERNET GATEWAY CONFIGURATION
resource "aws_internet_gateway" "gateway" {
    vpc_id = aws_vpc.this.id

    tags = {
        Name = "${var.cluster_name}-igw"
    }
}

# NAT GATEWAY CONFIGURATION
resource "aws_eip" "nat" {
    count = 3
    domain = "vpc"

}

resource "aws_nat_gateway" "nat" {
    count = 3
    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.public[count.index].id

}