output "target_group_dev_ids" {
  value = aws_instance.web_server[*].id
}

output "target_group_prod_ids" {
  value = aws_instance.web_server1[*].id
}