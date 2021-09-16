locals {
  private_subnets = [cidrsubnet(var.vpc_cidr_block, 3,0), cidrsubnet(var.vpc_cidr_block, 3,2), cidrsubnet(var.vpc_cidr_block, 3,4)]
  public_subnets = [cidrsubnet(var.vpc_cidr_block, 3,1), cidrsubnet(var.vpc_cidr_block, 3,3), cidrsubnet(var.vpc_cidr_block, 3,5)]
}

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
  cidr_block              = "${local.public_subnets[count.index]}"#+local.subnet_netnum_factor.public)}"
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
  cidr_block              = "${local.private_subnets[count.index]}"#local.subnet_netnum_factor.private)}"
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

##############################################################
#Transit GATEWAY
#######################################################################


# resource "aws_ec2_transit_gateway" "client_vpc-tgw" {
#   description                     = "client_vpc-transit-gateway"
#   amazon_side_asn                 = 64512 
# /*   Amazon side ASN: Autonomous System Number (ASN) of your Transit Gateway.
#    You can use an  existing ASN assigned to your network. If you don't have one,
#     you can  use a private ASN in the 64512-65534 or 4200000000-4294967294 range. */
#   auto_accept_shared_attachments  = "disable"
# /*   * Auto accept shared attachments: Automatically accept cross account
#    attachments that are attached to this Transit Gateway.In case if you
#     are planning to spread your TGW across multiple account. */
#   default_route_table_association = "enable"
# /*   * Default route table association: Automatically associate 
#   Transit Gateway attachments with this Transit Gateway's default route table. */
#   default_route_table_propagation = "enable"
#   /* * Default route table propagation: Automatically propagate Transit Gateway
#    attachments with this Transit Gateway's default route table */
#   dns_support                     = "enable"
# /*   * DNS Support: Enable Domain Name System resolution for VPCs attached to
#    this Transit Gateway(If you have multiple VPC, this will enable hostname
#     resolution between two VPC) */
#   vpn_ecmp_support                = "enable"
# /*   *VPN ECMP support: Equal-cost multi-path routing for VPN Connections that are
#    attached to this Transit Gateway.Equal Cost Multipath (ECMP) routing support 
#    between VPN connections. If connections advertise the same CIDRs, the traffic
#     is distributed equally between them. */
#   tags {
#     Name = "client_vpc-transit-gateway"
#   }
# }

# resource "aws_ec2_transit_gateway_vpc_attachment" "client_vpc-transit-gateway-attachment" {
#   transit_gateway_id = "${aws_ec2_transit_gateway.client_vpc-tgw.id}"
#   vpc_id             = "${var.vpc_id}"
#   dns_support        = "enable"

#   subnet_ids = "${element(aws_subnet.private_subnet.*.id, count.index)}"

#   tags =  {
#     Name = "client_vpc-tgw-vpc-attachment"
#   }
# }

# ##############################################################
# # AWS egress_only_internet_gateway
# #######################################################################


# resource "aws_egress_only_internet_gateway" "client_vpc-egress_only_internet_gateway" {
#   vpc_id = "${var.vpc_id}"

#   tags = {
#     Name = "client_vpc-egress_only_internet_gateway"
#   }
# }