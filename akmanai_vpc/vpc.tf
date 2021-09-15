/*==== The VPC ======*/
resource "aws_vpc" "client-vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "client-vpc"
    
  }
}
/*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.client-vpc.id}"
  tags = {
    Name        = "client-vpc-igw"
    
  }
}
/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}
/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 0)}"
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "client-vpc-nat"
    
  }
}
/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.client-vpc.id}"
  count                   = "${length(var.availability_zones)}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr_block, 3, count.index)}"
  availability_zone       = "${element(var.availability_zones,   count.index)}"
  map_public_ip_on_launch = true
  tags = {
    Name        = "client-vpc-${element(var.availability_zones, count.index)}-public-subnet"
    
  }
}
/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.client-vpc.id}"
  count                   = "${length(var.availability_zones)}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr_block, 3, count.index +3)}"
  availability_zone       = "${element(var.availability_zones,   count.index)}"
  map_public_ip_on_launch = false
  tags = {
    Name        = "client-vpc-${element(var.availability_zones, count.index)}-private-subnet"
    
  }
} 
/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.client-vpc.id}"
  tags = {
    Name        = "client-vpc-private-route-table"
    
  }
}
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.client-vpc.id}"
  tags = {
    Name        = "client-vpc-public-route-table"
    
  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}
/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = "${length(var.vpc_cidr_block)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "private" {
  count          = "${length(var.vpc_cidr_block)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}
