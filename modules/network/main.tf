# The three subnets in the same AZ
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "sdw" {
  cidr_block = var.vpc_mpls_cidr

  tags = {
    Name = "${var.vpc_name_prefix}-SDW-VPC"
  }
}

resource "aws_vpn_gateway" "vgw" {
  vpc_id = aws_vpc.sdw.id

  amazon_side_asn = var.amz_asn

  tags = {
    Name = "${var.vpc_name_prefix}-vgw"
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id = aws_vpc.sdw.id
  cidr_block = var.vpc_internet_cidr
}

resource "aws_vpc_ipv4_cidr_block_association" "third_cidr" {
  count = var.lan_if_enable == true ? 1 : 0

  vpc_id = aws_vpc.sdw.id
  cidr_block = var.vpc_lan_cidr
}

resource "aws_subnet" "mpls_subnet" {
  vpc_id = aws_vpc.sdw.id

  availability_zone = data.aws_availability_zones.available.names[0]

  cidr_block = var.vpc_mpls_cidr

  tags = {
    Name = "mpls-subnet"
  }
}

resource "aws_subnet" "internet_subnet" {
  vpc_id = aws_vpc.sdw.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = var.vpc_internet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "internet-subnet"
  }
}

resource "aws_subnet" "lan_subnet" {
  count = var.lan_if_enable == true ? 1 : 0
  vpc_id = aws_vpc.sdw.id
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "lan-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.sdw.id

  tags = {
    Name = "${var.vpc_name_prefix}-igw"
  }
}

resource "aws_route_table" "internet_rt" {
  vpc_id = aws_vpc.sdw.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "internet-route-table"
  }
}

resource "aws_route_table" "mpls_rt" {
  vpc_id = aws_vpc.sdw.id

  propagating_vgws = [aws_vpn_gateway.vgw.id]

  tags = {
    Name = "mpls-route-table"
  }
}

resource "aws_route_table" "lan_rt" {
  count = var.lan_if_enable == true ? 1 : 0
  vpc_id = aws_vpc.sdw.id

  route {
    cidr_block = var.vpc_lan_cidr
    network_interface_id = var.lan_interface
  }
}

resource "aws_route_table_association" "internet_rt_association" {
  subnet_id = aws_subnet.internet_subnet.id
  route_table_id = aws_route_table.internet_rt.id
}

resource "aws_route_table_association" "mpls_rt_association" {
  subnet_id = aws_subnet.mpls_subnet.id
  route_table_id = aws_route_table.mpls_rt.id
}

resource "aws_route_table_association" "lan_rt_association" {
  count = var.lan_if_enable == true ? 1 : 0
  subnet_id = aws_subnet.lan_subnet[count.index].id
  route_table_id = aws_route_table.lan_rt[count.index].id
}