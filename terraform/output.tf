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

output "mwaa_arn" {
  description = "The ARN of the MWAA Environment"
  value       = aws_mwaa_environment.mwaa_redshift.arn
}


output "mwaa_status" {
  description = "The status of the MWAA Environment"
  value       = aws_mwaa_environment.mwaa_redshift.status
}