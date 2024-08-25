
resource "aws_s3_bucket" "bucket_data" {
  bucket              = "demo-ml-datasets"
  object_lock_enabled = false
  tags                = {}
}


resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.bucket_mwaa.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "bucket_mwaa" {
  bucket = var.dag_bucket
  tags = {
    Environment = "test"
    Name        = var.dag_bucket
  }
  tags_all = {
    Environment = "test"
    Name        = var.dag_bucket
  }
}

resource "aws_s3_object" "dataset" {
  bucket   = aws_s3_bucket.bucket_data.id
  key      = "sample_housing/housing.csv"
  source   = "../data/housing.csv"
}


resource "aws_s3_object" "dag_main_script" {
  bucket   = aws_s3_bucket.bucket_mwaa.id
  key      = "dags/dag_redshift.py"
  source   = "../dags/dag_redshift.py"
}


resource "aws_s3_object" "dag_utils" {
  bucket   = aws_s3_bucket.bucket_mwaa.id
  key      = "dags/utils/execute_redshift_query.py"
  source   = "../dags/utils/execute_redshift_query.py"
}

resource "aws_s3_object" "reqs" {
  bucket = aws_s3_bucket.bucket_mwaa.id
  key    = "requires/requirements.txt"
  source = "../requirements.txt"
}

