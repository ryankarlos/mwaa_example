resource "aws_s3_bucket" "dag_bucket" {
  bucket = var.dag_bucket

  tags = {
    Name        = "mwaa-bucket"
    Environment = "test"
  }
}



resource "aws_db_instance" "default" {
  allocated_storage           = 10
  db_name                     = "mydb"
  engine                      = "mysql"
  engine_version              = "5.7"
  instance_class              = "db.t3.micro"
  manage_master_user_password = true
  username                    = "foo"
  parameter_group_name        = "default.mysql5.7"
  skip_final_snapshot  = true
}
