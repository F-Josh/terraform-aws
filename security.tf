resource "aws_security_group" "public_subnets_security" {
  name        = "public_subnets_security"
  description = "EC2 SG"
  vpc_id      = aws_vpc.main_vpc.id

  #####@#provide ingress and egress
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "public_subnets_security"
  }

  lifecycle {
    create_before_destroy = true
  }
}

## Private ec2 security group
resource "aws_security_group" "private_subnets_security" {
  name        = "private_subnets_security"
  description = "EC2 SG Private"
  vpc_id      = aws_vpc.main_vpc.id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  ## Allow all ICMP traffic to enable you ping from your servers for ssh 
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  #Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "public_subnets_security"
  }

  lifecycle {
    create_before_destroy = true
  }
}
