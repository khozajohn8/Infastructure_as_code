terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web_server" {
  ami                    = "ami-022e1a32d3f742bd8"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_server-sg.id]

  tags = {
    Name = "first_instance"
  }

}

resource "aws_security_group" "web_server-sg" {
  name        = "sec group for web_server"
  description = "Allow ssh and http inbound traffic"

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_server-sg"
  }
}