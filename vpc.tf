#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "paywallet" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "terraform-eks-paywallet-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_subnet" "paywallet" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.paywallet.id

  tags = tomap({
    "Name"                                      = "terraform-eks-paywallet-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_internet_gateway" "paywallet" {
  vpc_id = aws_vpc.paywallet.id

  tags = {
    Name = "terraform-eks-paywallet"
  }
}

resource "aws_route_table" "paywallet" {
  vpc_id = aws_vpc.paywallet.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.paywallet.id
  }
}

resource "aws_route_table_association" "paywallet" {
  count = 2

  subnet_id      = aws_subnet.paywallet.*.id[count.index]
  route_table_id = aws_route_table.paywallet.id
}
