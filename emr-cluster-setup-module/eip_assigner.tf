resource "aws_iam_role" "eip_assigner_lambda_role" {
  name = "eip_assigner_lambda_role"

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


resource "aws_iam_role_policy_attachment" "eip_assigner_lambda_policy" {
  policy_arn = aws_iam_policy.terraform_lambda_policy.arn
  role       = aws_iam_role.eip_assigner_lambda_role.name
}

resource "aws_iam_policy" "terraform_lambda_policy" {
  name = "eip_assigner_lambda_policy"
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
				"arn:aws:logs:${var.region_name}:${var.account_id}:log-group:/aws/lambda/eip-assigner-tf:*"
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:DescribeAddresses",
				"ec2:DescribeInstances",
				"ec2:AssociateAddress"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"elasticmapreduce:ListClusters",
				"elasticmapreduce:DescribeCluster",
				"elasticmapreduce:ListInstances"
			],
			"Resource": "*"
		}
	]
  })
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "functions/eip-assigner/lambda.py"
  output_path = "functions/eip-assigner/lambda.zip"
}

resource "aws_lambda_function" "eip-assigner-function" {
  function_name = "eip-assigner-tf--${var.account_id}"
  filename = "functions/eip-assigner/lambda.zip"
  handler = "lambda.lambda_handler"
  runtime = "python3.9"
  role = aws_iam_role.eip_assigner_lambda_role.arn
  timeout = 180
  environment {
    variables = {
      EIP_ALLOC_ID = var.eip_allocation_id
    }
  }
}