terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

resource "aws_instance" "data_producer" {
  ami           = "ami-0f89681a05a3a9de7"
  instance_type = "t2.micro"

  tags = {
    Name = "Test"
  }
}
