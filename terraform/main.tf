
resource "aws_mwaa_environment" "mwaa_redshift" {
  dag_s3_path                     = "dags/"
  environment_class               = var.environment_class
  execution_role_arn              = aws_iam_role.mwaa_role.arn
  max_workers                     = var.worker_scaling.max_workers
  min_workers                     = var.worker_scaling.min_workers
  name                            = var.name
  requirements_s3_path            = var.airflow_file_paths.requirements
  schedulers                      = var.number_schedulers
  source_bucket_arn               = aws_s3_bucket.bucket_mwaa.arn
  webserver_access_mode           = var.access_mode
  weekly_maintenance_window_start = var.maintenance_window
  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = var.logging_configuration.dags
    }
    scheduler_logs {
      enabled   = true
      log_level = var.logging_configuration.webserver
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
    security_group_ids = [aws_security_group.security_group.id]
    subnet_ids         = module.vpc.private_subnets
  }
}



resource "aws_ecs_cluster" "mwaa_ecs" {
  name = "mwaa-ecs"
  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


resource "aws_ecs_task_definition" "ecs_task_def" {
  family                   = "ecs-task-def"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 3072
  container_definitions = jsonencode([{
    name      = "redshift"
    essential = true
    image     = join(":", [aws_ecr_repository.ecr_repo.repository_url, "latest"])
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-group         = "/ecs/ecs-task-def"
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
  network_mode       = "awsvpc"
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}


resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier        = "redshift-cluster-1"
  cluster_type              = "multi-node"
  database_name             = "dev"
  iam_roles                 = [aws_iam_role.redshift_role.arn]
  master_username           = "awsuser"
  manage_master_password    = true
  node_type                 = var.redshift_node_type
  number_of_nodes           = var.redshift_nodes
  vpc_security_group_ids    = [aws_security_group.security_group.id]
  cluster_subnet_group_name = aws_redshift_subnet_group.this.name
  automated_snapshot_retention_period = 0
  skip_final_snapshot =  true
}


resource "aws_redshift_subnet_group" "this" {
  name       = "redshift-subnet-group"
  subnet_ids = ["${element(module.vpc.public_subnets, 0)}"]
}

resource "aws_ecr_repository" "ecr_repo" {
  name = "ecs-redshift"
  image_scanning_configuration {
    scan_on_push = true
  }
}
