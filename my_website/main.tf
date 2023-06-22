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
  region = var.region
# profile = ""
}

#create VPC

module "vpc" {
  source = "../modules/vpc"
  region                        = var.region
  project_name                  = var.project_name
  vpc_cidr                      = var.vpc_cidr
  public_subnet_az1_cidr        = var.public_subnet_az1_cidr
  public_subnet_az2_cidr        = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr   = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr   = var.private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr  = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr  = var.private_data_subnet_az2_cidr
}

resource "aws_instance" "web_server" {
  count = 2
  ami                    = "ami-022e1a32d3f742bd8"
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [module.security_group.ec2_security_group_id]
  subnet_id              = module.vpc.public_subnet_az1_id
  
  user_data              = file("ec2-user-data.sh")

  tags = {
    Name = "my-dev-${count.index}"
  }
}

resource "aws_instance" "web_server1" {
  count = 2
  ami                    = "ami-022e1a32d3f742bd8"
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [module.security_group.ec2_security_group_id]
  subnet_id              = module.vpc.public_subnet_az2_id
  
  user_data              = file("ec2-user-data.sh")

  tags = {
    Name = "my-staging-${count.index}"
  }
}

module "security_group" {
  source                        = "../modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

module "application_load_balancer" {
  source                        = "../modules/alb"
  project_name                  = module.vpc.project_name
  alb_security_group_id         = module.security_group.alb_security_group_id
  public_subnet_az1_id          = module.vpc.public_subnet_az1_id
  public_subnet_az2_id          = module.vpc.public_subnet_az2_id
  vpc_id                        = module.vpc.vpc_id
  certificate_arn               = module.acm.certificate_arn
}

module "acm" {
  source                        = "../modules/acm"
  domain_name                   = var.domain_name
  alternative_name              = var.alternative_name
}