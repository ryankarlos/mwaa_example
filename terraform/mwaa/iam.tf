resource "aws_iam_role" "mwaa_role" {
  name = "mwaa_role"
  path               = "/service-role/airflow.amazonaws.com/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_entities.json
  managed_policy_arns = [data.aws_iam_policy.ECSFullAccess.arn]
}


resource "aws_iam_role_policy" "mwaa_policy" {
  name = "mwaa_policy"
  policy = data.aws_iam_policy_document.mwaa_role_inline_policies.json
  role = aws_iam_role.mwaa_role.id
}
