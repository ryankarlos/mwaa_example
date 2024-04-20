variable "name" {
  description = "Name of MWAA Environment"
  default     = "demo-mwaa"
  type        = string
}

variable "region" {
  default = "eu-west-1"
  type    = string
}


variable "subnet_ids" {
  description = "list of private subnet ids to associate with airflow env"
  type        = list(string)
}

variable "security_group_ids" {
  description = "security group ids"
  type        = list(string)
}


variable "tags" {
  description = "Default tags"
  default     = { Name = "airflow_dsai", Environment = "non-prod" }
  type        = map(string)
}


variable "worker_scaling" {
  type        = object({ min_workers = number, max_workers = number })
  description = "Scaling configuration for workers when running task"
  default = {
    min_workers = 2
    max_workers = 10
  }
}

variable "number_schedulers" {
  description = "number of schedulers"
  type        = number
  default     = 2
}


variable "logging_configuration" {
  description = "Default logging level for scheduler, worker, webserver"
  default     = { "dags" : "INFO", "scheduler" : "INFO", "task" : "INFO", "webserver" : "INFO", "worker" : "INFO" }
  type        = map(string)
}

# need to work on making this PRIVATE in future.
variable "access_mode" {
  description = "mode of access for airflow ui"
  type        = string
  default     = "PUBLIC_ONLY"
}

variable "maintenance_window" {
  description = "day and time when environment is updated for maintenance"
  type        = string
  default     = "TUE:02:30"
}

variable "dag_bucket" {
  description = "bucket where dags and requirements files are stored"
  type        = string
  default     = "mwaa-sample-bucket"

}

variable "environment_class" {
  description = "aiflow env class"
  type        = string
  default     = "mw1.medium"
}

variable "airflow_file_paths" {
  description = "relative path to folder for dags and requirements txt in bucket"
  default     = { "dags" : "dags", "requirements" : "requires/requirements.txt" }
  type        = map(string)

}
