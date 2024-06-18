
resource "aws_s3_bucket" "bucket_data" {
  bucket              = "demo-ml-datasets"
  object_lock_enabled = false
  tags                = {}
}


resource "aws_s3_bucket" "bucket_mwaa" {
  bucket              = var.dag_bucket
  tags = {
    Environment = "test"
    Name        = var.dag_bucket
  }
  tags_all = {
    Environment = "test"
    Name        = var.dag_bucket
  }
}

