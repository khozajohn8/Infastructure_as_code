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

# create intances
module "ec2_instances" {
  source                        = "../modules/ec2" 
  ec2_security_group_id         = module.security_group.ec2_security_group_id
  public_subnet_az1_id          = module.vpc.public_subnet_az1_id
  public_subnet_az2_id          = module.vpc.public_subnet_az2_id
  ec2_instance_type             = var.ec2_instance_type 
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
  target_group_dev_ids          = module.ec2_instances.target_group_dev_ids
  
}

# Create AWS certificate manager
module "acm" {
  source                        = "../modules/acm"
  domain_name                   = var.domain_name
  alternative_name              = var.alternative_name
}

/*module "rds" {
  source                        = "../modules/rds-instance"
  database_subnet_az1_id        = module.vpc.database_subnet_az1_id
  db_security_group_id          = module.security_group.db_security_group_id
}*/

module "route_53" {
  source                             = "../modules/route53"
  domain_name                        = var.domain_name
  application_load_balancer_dns_name = module.application_load_balancer.application_load_balancer_dns_name
  application_load_balancer_zone_id  = module.application_load_balancer.application_load_balancer_zone_id
  record_name                        = var.record_name
}
