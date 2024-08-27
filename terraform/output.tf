output "bucket_arn" {
  value = local.bucket_arn
}

output "bucket_object_arn" {
  value = local.bucket_objects_arn
}

output "mwaa_webserver_url" {
  description = "The webserver URL of the MWAA Environment"
  value       = aws_mwaa_environment.mwaa_redshift.webserver_url
}

output "ssm_ecs" {
  description = "Value of SSM ECS"
  sensitive = true
  value       = aws_ssm_parameter.ecs_params.value
}


output "ssm_db" {
  description = "Value of SSM DB"
  sensitive = true
  value       = aws_ssm_parameter.db.value
}

output "ssm_network" {
  description = "Value of SSM network"
  sensitive = true
  value       = aws_ssm_parameter.network.value
}

output "ssm_sql_params" {
  description = "Value of SSM sql params"
  sensitive = true
  value       = aws_ssm_parameter.sql_params.value
}


output "s3_dataset_uri" {
  description = "Value of SSM S3 URI "
  sensitive = true
  value       = aws_ssm_parameter.s3_uri.value
}



output "redshift_cluster_id" {
  description = "Redshift cluster id"
  value       = aws_redshift_cluster.redshift_cluster.id
}


output "ecs_cluster_arn" {
  description = "ARN that identifies the cluster"
  value       = aws_ecs_cluster.mwaa_ecs.arn
}