
data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags ={
    Name = "stage-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.vpc.id
  count      =length(data.aws_availability_zones.available.names)
  cidr_block =element(var.pub_cidr, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "stage-public-subnet"
  }
}

resource "aws_subnet" "privatec" {
  vpc_id     = aws_vpc.vpc.id
  count      =length(data.aws_availability_zones.available.names)
  cidr_block =element(var.private_cidr, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "stage-private-subnet"
  }
}


resource "aws_subnet" "data" {
  vpc_id     = aws_vpc.vpc.id
  count      =length(data.aws_availability_zones.available.names)
  cidr_block =element(var.data_cidr, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "stage-data-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "stage-igw"
  }
}


resource "aws_eip" "eip" {
  vpc      = true
  tags ={
    Name = "stage-eip"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "gw NAT"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route"
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "Private-route"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_cidr)
  subnet_id      = aws_subnet.privatec[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "data" {
  count          = length(var.data_cidr)
  subnet_id      = aws_subnet.data[count.index].id
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "public" {
  count          = length(var.pub_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

