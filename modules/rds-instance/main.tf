# create the rds instance
resource "aws_db_instance" "db_instance" {
  engine                  = "mysql"
  engine_version          = "8.0.31"
  multi_az                = false
  identifier              = "dev-rds-instance"
  username                = "khozajohn"
  password                = "khozajohn123"
  instance_class          = "db.t2.micro"
  allocated_storage       = 200
  db_subnet_group_name    = var.database_subnet_az1_id
  vpc_security_group_ids  = [var.db_security_group_id]
  #availability_zone       = 
  db_name                 = "applicationdb"
  skip_final_snapshot     = true
}
