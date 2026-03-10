resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>"
}

resource "aws_db_subnet_group" "db_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.private_db_subnet_1.id, aws_subnet.private_db_subnet_2.id]
}

resource "aws_db_instance" "database" {
  allocated_storage = 20
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  db_name           = "mydb"
  username          = "admin"
  password          = random_password.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.db_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  multi_az             = true
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = false
}
