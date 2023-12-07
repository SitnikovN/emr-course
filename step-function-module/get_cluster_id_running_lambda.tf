resource "aws_iam_role" "get_cluster_id_running_lambda_role" {
  name = "get_cluster_id_running_lambda_role"

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


resource "aws_iam_role_policy_attachment" "get_cluster_id_running_lambda_policy_attch" {
  policy_arn = aws_iam_policy.get_cluster_id_running_lambda_policy.arn
  role       = aws_iam_role.get_cluster_id_running_lambda_role.name
}

resource "aws_iam_policy" "get_cluster_id_running_lambda_policy" {
  name = "get_cluster_id_running_lambda_policy"
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
				"arn:aws:logs:${var.region_name}:${var.account_id}:log-group:/aws/lambda/get_cluster_id_running:*"
			]
		},
      {
        Action = [
            "ec2:DescribeTags"
        ]
        Effect   = "Allow"
        Resource = [
          "*"
        ]
      },
      {
            "Action": [
                "elasticmapreduce:ListClusters",
                "elasticmapreduce:DescribeCluster",
                "elasticmapreduce:ListInstances"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }

	]
  })
}

data "archive_file" "get-cluster-id-running" {
  type        = "zip"
  source_file = "functions/get-cluster-id-running/lambda.py"
  output_path = "functions/get-cluster-id-running/lambda.zip"
}

resource "aws_lambda_function" "get-cluster-id-running-function" {
  function_name = "get-cluster-id-running-tf-${var.account_id}"
  filename = "functions/get-cluster-id-running/lambda.zip"
  handler = "lambda.lambda_handler"
  runtime = "python3.9"
  role = aws_iam_role.get_cluster_id_running_lambda_role.arn
  timeout = 180
}