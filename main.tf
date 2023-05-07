# Create a  VPC
# Create 2 public and 2 private subnets
# At least 2 private and 1 public Route table
# Create an Internet Gateway
# Launch EC2 in Private and public subnets
# Establish ssh connection to the instances in the private subnets
# Download updates for the private instances

### provider block......
provider "aws" {
  region  = "us-east-1"
  profile = "josh"
}

locals {
  vpc_cidr             = "10.0.0.0/16"
  public_cidr          = ["10.0.1.0/24", "10.0.2.0/24"]
  public_availability  = ["us-east-1a", "us-east-1b"]
  private_cidr         = ["10.0.3.0/24", "10.0.4.0/24"]
  private_availability = ["us-east-1c", "us-east-1d"]
  ec2_subnets          = [aws_subnet.public_subnet[0].id, aws_subnet.private_subnet[0].id]
  security_groups      = [aws_security_group.public_subnets_security.id, aws_security_group.private_subnets_security.id]
}

## Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block       = local.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.env_code} - main_vpc"
  }
}

## Create 2 public subnets for the vpc
resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = local.public_cidr[count.index]
  availability_zone       = local.public_availability[count.index]
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.env_code} - public_subnet-${count.index + 1}"
  }
}

## Create 2 private subnets
resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = local.private_cidr[count.index]
  availability_zone = local.private_availability[count.index]

  tags = {
    Name = "${var.env_code} - private_subnet-${count.index + 1}"
  }
}

## Create an internet gateway. Note that we only need one IGW
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.env_code} - internet_gateway"
  }
}

## Create 1 public Route table and routes inside of it and target IGW
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  ## Routes out to the internet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.env_code} - public_route_table"
  }
}

## Assosciate our route table to our 2 public subnets
resource "aws_route_table_association" "route_association" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

## Create 2 private Route tables and routes inside of it and target the NATGW
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  count  = 2

  ## Routes out to the internet
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = {
    Name = "${var.env_code} - private_route_table-${count.index + 1}"
  }
}

## Assosciate our private subnets to our private route tables
resource "aws_route_table_association" "private_route_association_1" {
  count          = 2
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

## Create the first Elastic IP EIP
resource "aws_eip" "elastic_ip" {
  ##instance = aws_instance.web.id
  count = 2
  vpc   = true
}

## Create the 2 NAT gateways and associate EIP to it
resource "aws_nat_gateway" "nat_gateway" {
  count         = 2
  allocation_id = aws_eip.elastic_ip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "${var.env_code} - nat_gateway-{count.index + 1}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.internet_gateway]
}
