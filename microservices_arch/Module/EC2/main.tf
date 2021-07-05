resource "aws_instance" "ec2_instance" {
  ami           = "ami-0f89681a05a3a9de7"
  instance_type = "t2.micro"
  associate_public_ip_address = true

  key_name         = "ssh-key"

  tags = {
    Name = "data_producer"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = file("${path.module}/aws_project.pub") 
}
