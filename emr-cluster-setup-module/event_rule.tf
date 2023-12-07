resource "aws_cloudwatch_event_rule" "emr_starting_rule" {
  name        = "emr-starting-rule"
  description = "Capture EMR cluster starting events"

  event_pattern = jsonencode({
    "source" : [
      "aws.emr"
    ],
    "detail-type" : [
      "EMR Cluster State Change"
    ],
    "detail" : {
      "state" : [
        "STARTING"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "emr_starting_target" {
  rule      = aws_cloudwatch_event_rule.emr_starting_rule.name
  arn       = aws_lambda_function.eip-assigner-function.arn
}

resource "aws_lambda_permission" "allow_emr_starting" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.eip-assigner-function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.emr_starting_rule.arn
}