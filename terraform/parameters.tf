resource "aws_ssm_parameter" "ecs_params" {
  name        = "/mwaa/redshift/ECS"
  description = "ECS parameters dict"
  type        = "String"
  value       = <<EOF
  {
    "cluster_name": aws_ecs_cluster.mwaa_ecs.name , 
    "service": "ecs-service", 
    "container_name": "redshift", 
    "launch_type": "FARGATE", 
    "task_definition_arn": aws_ecs_task_definition.ecs_task_def.arn,  
    "logs_group":  aws_ecs_task_definition.ecs_task_def.container_definitions.logConfiguration.options["awslogs-group"]
    "logs_stream_prefix": "ecs/redshift"
    }
  EOF

}

resource "aws_ssm_parameter" "db" {
  name        = "/mwaa/redshift/DB"
  description = "Redshift DB"
  type        = "String"
  value       = aws_redshift_cluster.redshift_cluster.database_name

}

resource "aws_ssm_parameter" "host" {
  name        = "/mwaa/redshift/HOST"
  description = "Redshift host"
  type        = "String"
  value       = aws_redshift_cluster.redshift_cluster.id

}


resource "aws_ssm_parameter" "network" {
  name        = "/mwaa/redshift/NETWORK"
  description = "Redshift network"
  type        = "String"
  value       = <<EOF
  {
    "vpc_id": module.vpc.vpc_id, 
    "security_group_name": aws_security_group.security_group.name
  }
  EOF

}

resource "aws_ssm_parameter" "cluster_id" {
  name        = "/mwaa/redshift/CLUSTER_ID"
  description = "Redshift cluster identifier"
  type        = "String"
  value       = aws_redshift_cluster.redshift_cluster.cluster_identifier
}

resource "aws_ssm_parameter" "port" {
  name        = "/mwaa/redshift/PORT"
  description = "Redshift port"
  type        = "String"
  value       = "5439"

}

resource "aws_ssm_parameter" "schema" {
  name        = "/mwaa/redshift/SCHEMA"
  description = "Redshift schema"
  type        = "String"
  value       = "public"
}

resource "aws_ssm_parameter" "table" {
  name        = "/mwaa/redshift/TABLE"
  description = "Redshift table"
  type        = "String"
  value       = "housing"

}

resource "aws_ssm_parameter" "s3_uri" {
  name        = "/mwaa/redshift/S3_URI"
  description = "Redshift host"
  type        = "String"
  value       = join("", ["s3://", aws_s3_bucket.bucket_data.id, "/",  "aws_s3_object.dataset.key"]) 

}


resource "aws_ssm_parameter" "sql_params" {
  name        = "/mwaa/redshift/SQL_PARAMS"
  description = "params to be used in sql query redshift"
  type        = "String"
  value       = <<EOF
  {
    "population": 2000, 
    "housing_median_age":52, 
    "median_house_value": 498000
  }
  EOF

}


import {
  id = "/mwaa/redshift/SQL_PARAMS"
  to = aws_ssm_parameter.sql_params
}


import {
  id = "/mwaa/redshift/S3_URI"
  to = aws_ssm_parameter.s3_uri
}