output "target_group_dev_ids" {
  value = aws_instance.web_server[*].id
}