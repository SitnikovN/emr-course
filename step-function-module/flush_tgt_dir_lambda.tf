resource "aws_iam_role" "flush_tgt_dir_lambda_role" {
  name = "flush_tgt_dir_lambda_role"

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


resource "aws_iam_policy" "flush_tgt_dir_lambda_policy" {
  name = "flush_tgt_dir_lambda_policy"
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
				"arn:aws:logs:${var.region_name}:${var.account_id}:log-group:/aws/lambda/flush_tgt_dir:*"
			]
		},
      {
        Action = [
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
           var.bucket_arn,
           "${var.bucket_arn}/*",
        ]
      }
	]
  })
}


resource "aws_iam_role_policy_attachment" "flush_tgt_dir_lambda_policy_attch" {
  policy_arn = aws_iam_policy.flush_tgt_dir_lambda_policy.arn
  role       = aws_iam_role.flush_tgt_dir_lambda_role.name
}


data "archive_file" "lambda_flush" {
  type        = "zip"
  source_file = "functions/flush-tgt-dir/lambda.py"
  output_path = "functions/flush-tgt-dir/lambda.zip"
}

resource "aws_lambda_function" "flush-tgt-dir-function" {
  function_name = "flush-tgt-dir-tf-${var.account_id}"
  filename      = "functions/flush-tgt-dir/lambda.zip"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.flush_tgt_dir_lambda_role.arn
  timeout       = 180
  environment {
    variables = {
          BUCKET_NAME = var.bucket_name
          TGT_PREFIX = var.tgt_prefix
    }
  }
}