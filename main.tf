# Create a  VPC
# Create 2 public and 2 private subnets
# At least 2 private and 1 public Route table
# Create an Internet Gateway
# Launch EC2 in Private and public subnets
# Establish ssh connection to the instances in the private subnets
# Download updates for the private instances

### provider block......
provider "aws" {
  region = "us-east-1"
  profile =  "josh"

}

## Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main_vpc"
  }
}

## Create first public subnet for vpc
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public_subnet_1"
  }
}

## create your second public subnet
resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public_subnet_2"
  }
}

## Create private subnet
resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "private_subnet_1"
  }
}

## Create second private subnet
resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1d"

  tags = {
    Name = "private_subnet_2"
  }
}

## Create an internet gateway. Note that we only need one IGW
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "internet_gateway"
  }
}

## Create 1 public Route tables and routes inside of it and target IGW
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  ## Routes out to the internet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "public_route_table"
  }
}

## Assosciate our route table to our first public subnets
resource "aws_route_table_association" "route_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

## Assosciate our route table to our second public subnets
resource "aws_route_table_association" "route_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}


## Create a private Route table and routes inside of it and target the NATGW
resource "aws_route_table" "private_route_table_1" {
  vpc_id = aws_vpc.main_vpc.id

  ## Routes out to the internet
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  }

  tags = {
    Name = "private_route_table_1"
  }
}

## Create a second private Route table and routes inside and target the NATGW
resource "aws_route_table" "private_route_table_2" {
  vpc_id = aws_vpc.main_vpc.id

  ## Routes out to the internet
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_2.id
  }

  tags = {
    Name = "private_route_table_2"
  }
}

## Assosciate our first private route table to our first private subnets
resource "aws_route_table_association" "private_route_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table_1.id
}

## Assosciate our second private route table to our second private subnets
resource "aws_route_table_association" "private_route_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table_2.id
}

## Create the first Elastic IP EIP
resource "aws_eip" "elastic_ip_1" {
  ##instance = aws_instance.web.id
  vpc        = true
}

## Create the first NAT gateway and associate EIP to it
resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.elastic_ip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "nat_gateway_1"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.internet_gateway]
}

## Create the second EIP
resource "aws_eip" "elastic_ip_2" {
  ##instance = aws_instance.web.id
  vpc      = true
}

## Create a second NAT gateway and associate EIP2 to it
resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.elastic_ip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id

  tags = {
    Name = "nat_gateway_2"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.internet_gateway]
}

##
#### Create 1 ec2 instance and host it in the public subnet
resource "aws_instance" "public_instance" {
  ami                     = "ami-007855ac798b5175e"
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.public_subnet_1.id
  vpc_security_group_ids  = [aws_security_group.public_subnets_security.id]
  key_name                = "My_September_Key"

  tags = {
    Name = "public_instance"
  }
}

## Create 1  ec2 instance and host it in the private subnet
resource "aws_instance" "private_instance" {
  ami                     = "ami-007855ac798b5175e"
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.private_subnet_1.id
  key_name               = "My_September_Key"
  vpc_security_group_ids = [aws_security_group.private_subnets_security.id]

  tags = {
    Name = "private_instance"
  }
}
