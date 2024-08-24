
locals {
  bucket_arn         = aws_s3_bucket.bucket_mwaa.arn
  bucket_objects_arn = join("/", [local.bucket_arn, "*"])
  account_id = data.aws_caller_identity.current.account_id
}


data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "mwaa_role_inline_policies" {
  statement {
    actions   = ["airflow:PublishMetrics"]
    resources = ["arn:aws:airflow:${var.region}:${data.aws_caller_identity.current.account_id}:environment/*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["s3:*"]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:GetLogEvents",
      "logs:GetLogGroupFields",
      "logs:GetLogRecord",
      "logs:GetQueryResults",
      "logs:PutLogEvents",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:*",
    ]
  }
  statement {
    actions = [
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:RunTask",
      "logs:DescribeLogGroups",
    ]
    effect   = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
    ]
    effect   = "Allow"
    resources = ["arn:aws:sqs:${var.region}:*:airflow-celery-*"]
  }
  statement {
    actions = ["iam:PassRole"]
    condition {
      test     = "StringLike"
      values   = ["ecs-tasks.amazonaws.com"]
      variable = "iam:PassedToService"
    }
    effect   = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:PutKeyPolicy",
    ]
    condition {
      test     = "StringEquals"
      values   = [
          "sqs.eu-west-1.amazonaws.com",
          "s3.eu-west-1.amazonaws.com",
        ]
      variable = "kms:ViaService"
    }
    effect   = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
                "cloudwatch:PutMetricData",
                "sts:AssumeRole"
            ]
    resources = ["*"]
    effect = "Allow"
  }
  statement {
    actions= [
        "secretsmanager:CancelRotateSecret",
        "secretsmanager:CreateSecret",
        "secretsmanager:DeleteSecret",
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetRandomPassword",
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:ListSecretVersionIds",
        "secretsmanager:ListSecrets",
        "secretsmanager:PutSecretValue",
        "secretsmanager:RemoveRegionsFromReplication",
        "secretsmanager:ReplicateSecretToRegions",
        "secretsmanager:RestoreSecret",
        "secretsmanager:RotateSecret",
        "secretsmanager:StopReplicationToReplica",
        "secretsmanager:UpdateSecret",
        "secretsmanager:UpdateSecretVersionStage"
    ]
    resources = [
        "arn:aws:secretsmanager:*:*:airflow/connections/*",
        "arn:aws:secretsmanager:*:*:airflow/variables/*",
    ]
    effect =  "Allow"
  }
}

data "aws_iam_policy_document" "assume_role_entities" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = [
                    "airflow.amazonaws.com",
                    "airflow-env.amazonaws.com",
                    "ecs-tasks.amazonaws.com"
                ]
    }
    effect = "Allow"
  }
}


data "aws_iam_policy" "ECSFullAccess" {
  arn ="arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

data "aws_availability_zones" "available" {
  state = "available"
}



data "http" "local_ip" {
  url = "http://ipinfo.io/ip"
}


locals {
  azs         = slice(data.aws_availability_zones.available.names, 0, 2)
}
