resource "aws_vpc" "QAD-slalom" {
  cidr_block = "10.20.8.0/22"

  tags = {
    Name        = "QAD-slalom"    
  }
}


resource "aws_subnet" "public_subnet" {
  count = "${length(var.public_subnet_cidr_block)}"

  vpc_id     = "${aws_vpc.QAD-slalom.id}"
  cidr_block = "${element(var.public_subnet_cidr_block, count.index)}"

  availability_zone = "${element(var.availability_zones, count.index)}"

  tags = {
    Name = "QAD_public_subnet_${count.index+1} "
  }
}

resource "aws_subnet" "private_subnet" {
  count = "${length(var.private_subnet_cidr_block)}"

  vpc_id     = "${aws_vpc.QAD-slalom.id}"
  cidr_block = "${element(var.private_subnet_cidr_block, count.index)}"

  availability_zone = "${element(var.availability_zones, count.index)}"

  tags = {
    Name = "QAD_private_subnet_${count.index+1}"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.QAD-slalom.id}"
  tags = {
    Name="QAD_GW"
  }
}

# EIP and NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name="QAD_EIP_for_NAT_GW"
  }
}
# Nat_GW
resource "aws_nat_gateway" "natgw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 1)}"

  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name="QAD_natgw"
  }
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.QAD-slalom.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags = {
    Name="QAD_RT"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  count = "${length(aws_subnet.public_subnet.*.id)}"

  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.QAD-slalom.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natgw.id}"
  }
  tags = {
    Name="QAD_PRT"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  count = "${length(aws_subnet.private_subnet.*.id)}"

  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}
