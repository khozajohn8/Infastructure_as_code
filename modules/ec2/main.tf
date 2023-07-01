#Create AWS instances
resource "aws_instance" "web_server" {
  count = 2
  ami                    = "ami-022e1a32d3f742bd8"
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [var.ec2_security_group_id]
  subnet_id              = var.public_subnet_az1_id
  
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
  vpc_security_group_ids = [var.ec2_security_group_id]
  subnet_id              = var.public_subnet_az2_id
  
  user_data              = file("ec2-user-data.sh")

  tags = {
    Name = "my-prod-${count.index}"
  }
}