#based on 
#https://gitlab.com/mrcrilly/terraform-10x-webserver/-/blob/master/webserver.tf

variable "tag_name" {
  default = "EC2-diamond"
}

# VPC
resource "aws_vpc" "test" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = var.tag_name
  }
}

# Subnet
resource "aws_subnet" "webserver" {
  vpc_id     = aws_vpc.test.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "${var.tag_name}-webserver"
  }
}

# Route Table
resource "aws_route_table" "default" {
  vpc_id = aws_vpc.test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.tag_name
  }
}

# This associates our route table to our subnet, making
# the subnet use the route table for its routing rules.
resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.webserver.id
  route_table_id = aws_route_table.default.id
}

# Network ACL: we just allow everything
resource "aws_network_acl" "webserver" {
  vpc_id = aws_vpc.test.id

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
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test.id

  tags = {
    Name = var.tag_name
  }
}

# Security Group: 80 and 22 only, plus all egress.
resource "aws_security_group" "protected" {
  name        = "protected"
  description = "Only allows HTTP and SSH"
  vpc_id      = aws_vpc.test.id

  
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

# An EIP isn't strictly required, but I like
# ensure the IP is static and in my control as
# and when I can.
resource "aws_eip" "webserver" {
  instance = aws_instance.webserver.id
  vpc      = true
  depends_on = ["aws_internet_gateway.igw"]
}


# Keypair: replace with your own PUBLIC key.
resource "aws_key_pair" "webserver" {
  key_name   = "webserver-keypair"
  public_key = file("${path.module}/aws_project.pub") 
}

# Using a custom AMI, build with Packer, is a better option than this...


# A simple EC2 Instance. Note how we're using all the resources
# we defined and created above. Very little is hard coded and
# what is hard coded could easily be abstracted into variables
resource "aws_instance" "webserver" {
  ami                     = "ami-0f89681a05a3a9de7"
  availability_zone       = "eu-west-1a"
  instance_type           = "t2.micro"
  key_name                = aws_key_pair.webserver.key_name
  vpc_security_group_ids  = [aws_security_group.protected.id]
  subnet_id               = aws_subnet.webserver.id
  
  root_block_device {
    volume_size = 50
  }

  tags = {
    Name = "${var.tag_name}-webserver-01"
  }
}

# Outputs allow us to expose internal Terraform state,
# such as public (or private) IP addresses and other
# key information. This simple output gives us the
# EC2 Instance's public IP so that we don't have to
# hunt for it in the AWS Console.
output "instance_ip_addr" {
  value = aws_eip.webserver.public_ip
}
