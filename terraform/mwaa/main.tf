resource "aws_mwaa_environment" "airflow" {
  dag_s3_path                     = var.airflow_file_paths.dags
  environment_class               = var.environment_class
  execution_role_arn              = aws_iam_role.mwaa_role.arn
  max_workers                     = var.worker_scaling.max_workers
  min_workers                     = var.worker_scaling.min_workers
  name                            = var.name
  requirements_s3_path            = var.airflow_file_paths.requirements
  schedulers                      = var.number_schedulers
  source_bucket_arn               = aws_s3_bucket.dag_bucket.arn
  webserver_access_mode           = var.access_mode
  weekly_maintenance_window_start = var.maintenance_window
  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = var.logging_configuration.dags
    }
    scheduler_logs {
      enabled   = true
      log_level = var.logging_configuration.scheduler
    }
    task_logs {
      enabled   = true
      log_level = var.logging_configuration.task
    }
    webserver_logs {
      enabled   = true
      log_level = var.logging_configuration.webserver
    }
    worker_logs {
      enabled   = true
      log_level = var.logging_configuration.worker
    }
  }
  network_configuration {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }
}


resource "aws_s3_bucket" "dag_bucket" {
  bucket = var.dag_bucket
}
