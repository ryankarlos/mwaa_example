

resource "aws_mwaa_environment" "mwaa_redshift" {
  dag_s3_path                      = "dags/"
  environment_class                = var.environment_class
  execution_role_arn               = aws_iam_role.mwaa_role.arn
  max_workers                     = var.worker_scaling.max_workers
  min_workers                     = var.worker_scaling.min_workers
  name                            = var.name
  requirements_s3_path            = var.airflow_file_paths.requirements
  schedulers                      = var.number_schedulers
  source_bucket_arn                = aws_s3_bucket.bucket_mwaa.arn
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
    security_group_ids = module.vpc.default_security_group_id
    subnet_ids         = module.vpc.private_subnets
  }
}



resource "aws_ecs_cluster" "mwaa_ecs" {
  name     = "mwaa-ecs"
  configuration {
    execute_command_configuration {
      logging    = "DEFAULT"
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
  container_definitions = jsonencode([{
    name        = "redshift"
    cpu              = 1024
    memory           = 3072
    essential        = true
    image            = join(":", [aws_ecr_repository.ecr_repo.repository_url, "latest"])
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
  network_mode             = "awsvpc"
  task_role_arn            = "arn:aws:iam::${local.account_id}:role/ecsTaskRole"
  execution_role_arn       = "arn:aws:iam::${local.account_id}:role/ecsTaskExecutionRole"
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}

resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier                   = "redshift-cluster-1"
  cluster_subnet_group_name            = "default"
  cluster_type                         = "multi-node"
  database_name                        = "dev"
  iam_roles                            = ["arn:aws:iam:::role/RedshiftRole", "arn:aws:iam::${local.account_id}:role/aws-service-role/redshift.amazonaws.com/AWSServiceRoleForRedshift"]
  master_username                      = "awsuser"
  manage_master_password               = true
  node_type                            = "dc2.large"
  number_of_nodes                      = 2
  vpc_security_group_ids               = ["sg-0afdf2d5ce4c8ed3e"]
}


resource "aws_ecr_repository" "ecr_repo" {
  name                 = "ecs-redshift"
  image_scanning_configuration {
    scan_on_push = true
  }
}