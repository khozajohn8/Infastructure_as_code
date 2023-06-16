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
  count = 2
  ami                    = "ami-022e1a32d3f742bd8"
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [module.security_group.ec2_security_group_id]
  user_data              = file("ec2-user-data.sh")

  tags = {
    Name = "my-machine-${count.index}"
  }

}

module "security_group" {
  source = "../modules/security_groups"
  
}