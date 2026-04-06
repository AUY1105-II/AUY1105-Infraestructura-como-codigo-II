resource "aws_vpc" "mi_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "mi-vpc"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.mi_vpc.id
}

resource "aws_s3_bucket" "vpc_flow_logs" {
  bucket_prefix = "vpc-flow-logs-"
  force_destroy = true
}

resource "aws_flow_log" "mi_vpc_flow_log" {
  vpc_id               = aws_vpc.mi_vpc.id
  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = aws_s3_bucket.vpc_flow_logs.arn
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mi_vpc.id
  tags = {
    Name = "mi-igw"
  }
}

resource "aws_subnet" "subnet_publica_1" {
  vpc_id                  = aws_vpc.mi_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "subnet-publica-1"
  }
}

resource "aws_subnet" "subnet_publica_2" {
  vpc_id                  = aws_vpc.mi_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "subnet-publica-2"
  }
}

resource "aws_subnet" "subnet_privada_1" {
  vpc_id            = aws_vpc.mi_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet-privada-1"
  }
}

resource "aws_subnet" "subnet_privada_2" {
  vpc_id              = aws_vpc.mi_vpc.id
  cidr_block          = "10.0.4.0/24"
  availability_zone   = "us-east-1b"
  tags = {
    Name = "subnet-privada-2"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet_publica_1.id
  tags = {
    Name = "nat-gw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.mi_vpc.id
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.subnet_publica_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.subnet_publica_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.mi_vpc.id
  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.subnet_privada_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.subnet_privada_2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}