resource "aws_iam_role" "step_function_role" {
  name = "example-state-machine-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "step_function_role_policy" {
  name   = "step_function_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "logs:CreateLogGroup",
        "Resource" : "arn:aws:logs:${var.region_name}:${var.account_id}:*"
      },

      {
        "Action" = [
          "s3:ListBucket",
        ]
        "Effect"   = "Allow"
        "Resource" = [
          var.bucket_arn,
          "${var.bucket_arn}/*",
        ]
      },
      {
        "Action"   = ["lambda:InvokeFunction"],
        "Effect"   = "Allow",
        "Resource" = [
          aws_lambda_function.flush-tgt-dir-function.arn,
          aws_lambda_function.get-cluster-id-running-function.arn,
          aws_lambda_function.src-check-files-function.arn
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : "elasticmapreduce:AddJobFlowSteps",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_function_policy" {
  policy_arn = aws_iam_policy.step_function_role_policy.arn
  role       = aws_iam_role.step_function_role.name
}


resource "aws_sfn_state_machine" "sfn_state_machine" {
  name       = var.step_function_name
  role_arn   = aws_iam_role.step_function_role.arn
  definition = templatefile("${path.module}/statemachine/statemachine.asl.json", {
    daily_checker_lambda       = aws_lambda_function.src-check-files-function.arn
    clear_tgt_folder_lambda    = aws_lambda_function.flush-tgt-dir-function.arn
    get_cluster_running_lambda = aws_lambda_function.get-cluster-id-running-function.arn
    spark_app_bucket           = var.spark_app_bucket_name
    data_bucket_name           = var.bucket_name
    tgt_prefix                 = var.tgt_prefix
    src_prefix                 = var.raw_prefix
  }
  )
}