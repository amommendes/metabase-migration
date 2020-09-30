
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_security_group" "metabase_sg" {
  name        = "Allow Databases"
  description = "Allow Database clients"
  vpc_id      = aws_vpc.metabase-vpc.id

  dynamic "ingress" {
    for_each = var.metabase_ingress
    content {
      description = ingress.value["description"]
      from_port   = ingress.key
      to_port     = ingress.key
      protocol    = "tcp"
      cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "metabase"
  }
}

resource "aws_vpc" "metabase-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true" #gives you an internal domain name
    enable_dns_hostnames = "true" #gives you an internal host name
    enable_classiclink = "false"
    instance_tenancy = "default"
    tags = {
        Name = "metabase-migration"
    }
}

# Internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.metabase-vpc.id

  tags = {
    Name = "Metabase"
    Provisioner = "Terraform"
  }
}

resource "aws_subnet" "metabase-subnet-1" {
    vpc_id = aws_vpc.metabase-vpc.id
    cidr_block = "10.0.0.0/17"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = data.aws_availability_zones.available.names[0]
    
    tags = {
        Name = "metabase-subnet-1"
    }
}

resource "aws_subnet" "metabase-subnet-2" {
    vpc_id = aws_vpc.metabase-vpc.id
    cidr_block = "10.0.128.0/17"
    availability_zone = data.aws_availability_zones.available.names[1]
    tags = {
        Name = "metabase-subnet-2"
    }
}

# Routing table
resource "aws_route_table" "metabase-route" {
  vpc_id = aws_vpc.metabase-vpc.id

  tags = {
    Name        = "Metabase-migration"
    Provisioner = "Terraform"
  }
}

# Route the internet bound traffic via Internet Gateway
resource "aws_route" "gateway_route" {
  route_table_id         = aws_route_table.metabase-route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.metabase-subnet-1.id
  route_table_id = aws_route_table.metabase-route.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.metabase-subnet-2.id
  route_table_id = aws_route_table.metabase-route.id
}

resource "aws_db_subnet_group" "metabase-group" {
  name       = "metabase-migration-group"
  subnet_ids = [aws_subnet.metabase-subnet-2.id, aws_subnet.metabase-subnet-1.id]

  tags = {
    Name = "Metabase subnet group"
  }
}