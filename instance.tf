#### Create an ec2 instance and host it in the public and private subnets

data "aws_ami" "ubuntu_ami" {
  ##executable_users = ["self"]
  most_recent      = true
  owners           = ["099720109477"] ##Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "public_instance" {
  ami                    = data.aws_ami.ubuntu_ami.id
  instance_type          = "t2.micro"
  subnet_id              = local.ec2_subnets[0]
  vpc_security_group_ids = [local.security_groups[0]]
  key_name               = "My_September_Key"
  user_data              = base64encode(file("deploy.sh"))
  tags = {
    Name = "${var.env_code} - ${var.instance_name[0]}-instance"
  }
}
