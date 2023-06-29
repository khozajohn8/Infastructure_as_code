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
  source                        = "../modules/vpc"
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

#create nat gateways

module "nat_gateway" {
  source                        = "../modules/nat-gateway"
  public_subnet_az1_id          = module.vpc.public_subnet_az1_id    
  internet_gateway              = module.vpc.internet_gateway
  public_subnet_az2_id          = module.vpc.public_subnet_az2_id
  vpc_id                        = module.vpc.vpc_id
  private_app_subnet_az1_id     = module.vpc.private_app_subnet_az1_id
  private_data_subnet_az1_id    = module.vpc.private_data_subnet_az1_id
  private_app_subnet_az2_id     = module.vpc.private_app_subnet_az2_id
  private_data_subnet_az2_id    = module.vpc.private_data_subnet_az2_id
  
}

#Create AWS instances
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

#Create AWS instances
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

# Create security group
module "security_group" {
  source                        = "../modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

# Rreate application load balancer
module "application_load_balancer" {
  source                        = "../modules/alb"
  project_name                  = module.vpc.project_name
  alb_security_group_id         = module.security_group.alb_security_group_id
  public_subnet_az1_id          = module.vpc.public_subnet_az1_id
  public_subnet_az2_id          = module.vpc.public_subnet_az2_id
  vpc_id                        = module.vpc.vpc_id
  certificate_arn               = module.acm.certificate_arn
}

# Create AWS certificate manager
module "acm" {
  source                        = "../modules/acm"
  domain_name                   = var.domain_name
  alternative_name              = var.alternative_name
}

module "rds" {
  source                        = "../modules/rds-instance"
  database_subnet_az1_id        = module.vpc.database_subnet_az1_id
  db_security_group_id          = module.security_group.db_security_group_id
}
