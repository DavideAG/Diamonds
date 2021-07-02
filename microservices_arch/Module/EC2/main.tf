
resource "aws_instance" "data_producer" {
  ami           = "ami-0f89681a05a3a9de7"
  instance_type = "t2.micro"

  tags = {
    Name = "Test"
  }
}

