variable "project_name" {}
variable "alb_security_group_id" {}
variable "public_subnet_az1_id" {}
variable "public_subnet_az2_id" {}
variable "vpc_id" {}
variable "certificate_arn" {}

variable "target_group_dev_ids" {
  description = "List of target group instance IDs"
  type        = list(string)
}