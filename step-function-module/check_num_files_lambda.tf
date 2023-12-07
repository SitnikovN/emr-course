resource "aws_iam_role" "check_num_files_lambda_role" {
  name = "check_num_files_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "check_num_files_lambda_policy" {
  policy_arn = aws_iam_policy.terraform_lambda_policy.arn
  role       = aws_iam_role.check_num_files_lambda_role.name
}

resource "aws_iam_policy" "terraform_lambda_policy" {
  name = "check_num_files_lambda_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    "Statement": [
		{
			"Effect": "Allow",
			"Action": "logs:CreateLogGroup",
			"Resource": "arn:aws:logs:${var.region_name}:${var.account_id}:*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"logs:CreateLogStream",
				"logs:PutLogEvents"
			],
			"Resource": [
				"arn:aws:logs:${var.region_name}:${var.account_id}:log-group:/aws/lambda/check_num_files:*"
			]
		}
	]
  })
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "functions/src-check-files/lambda.py"
  output_path = "functions/src-check-files/lambda.zip"
}

resource "aws_lambda_function" "src-check-files-function" {
  function_name = "src-check-num-of-files-tf-${var.account_id}"
  filename = "functions/src-check-files/lambda.zip"
  handler = "lambda.lambda_handler"
  runtime = "python3.9"
  role = aws_iam_role.check_num_files_lambda_role.arn
  timeout = 180
}