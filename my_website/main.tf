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
  count = 4
  ami                    = "ami-022e1a32d3f742bd8"
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [aws_security_group.web_server-sg.id]

  tags = {
    Name = "my-machine-${count.index}"
  }

}

resource "aws_security_group" "web_server-sg" {
  name        = "sg_4_web_server"
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