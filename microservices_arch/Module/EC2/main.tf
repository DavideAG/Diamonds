#based on 
#https://gitlab.com/mrcrilly/terraform-10x-webserver/-/blob/master/webserver.tf

# VPC
resource "aws_vpc" "diamond_vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = var.tag_name
  }
}

# Subnet
resource "aws_subnet" "diamond_subnet" {
  vpc_id     = aws_vpc.diamond_vpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.tag_name}-subnet"
  }
}

# Route Table
resource "aws_route_table" "diamond_default_route_table" {
  vpc_id = aws_vpc.diamond_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.EC2_diamond_igw.id
  }

  tags = {
    Name = var.tag_name
  }
}

# This associates our route table to our subnet, making
# the subnet use the route table for its routing rules.
resource "aws_route_table_association" "diamond_default_route_table_association" {
  subnet_id      = aws_subnet.diamond_subnet.id
  route_table_id = aws_route_table.diamond_default_route_table.id
}


# Network ACL: we just allow everything
resource "aws_network_acl" "diamond_network_acl" {
  vpc_id = aws_vpc.diamond_vpc.id

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = var.tag_name
  }
}

# Internet Gateway so that we can talk over the public
# Internet.
resource "aws_internet_gateway" "EC2_diamond_igw" {
  vpc_id = aws_vpc.diamond_vpc.id

  tags = {
    Name = var.tag_name
  }
}

# Security Group: 22 only, plus all egress.
resource "aws_security_group" "protected" {
  name        = "protected"
  description = "Only allows SSH"
  vpc_id      = aws_vpc.diamond_vpc.id

  
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


# Keypair: replace with your own PUBLIC key.
resource "aws_key_pair" "diamond_key_pair" {
  key_name   = "diamond-keypair"
  public_key = file("${path.module}/aws_project.pub") 
}


# A simple EC2 Instance.
resource "aws_instance" "diamond_ec2_instance" {
  ami                     = "ami-0f89681a05a3a9de7"
  availability_zone       = var.availability_zone
  instance_type           = "t2.micro"
  key_name                = aws_key_pair.diamond_key_pair.key_name
  vpc_security_group_ids  = [aws_security_group.protected.id]
  subnet_id               = aws_subnet.diamond_subnet.id
  
  root_block_device {
    volume_size = 50
  }

  /* provisioner "file" {
    connection {
        type     = "ssh"
        user     = "ec2-user"
        password = "${var.root_password}"
        host     = "${var.host}"
      }

    source      = "${path.module}/data_producer.py"
    destination = "/home/ec2-user/data_producer.py"
  } */

  tags = {
    Name = "${var.tag_name}-ec2"
  }
}

# An EIP isn't strictly required, but I like
# ensure the IP is static and in my control as
# and when I can.
resource "aws_eip" "diamond_eip" {
  instance = aws_instance.diamond_ec2_instance.id
  vpc      = true
}


