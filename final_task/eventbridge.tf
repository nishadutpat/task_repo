resource "aws_cloudwatch_event_rule" "s3_event_rule" {
  name        = "s3-upload-rule"
  description = "Triggers Step Function when a new file is uploaded to S3"

  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name": ["data-buck-finaltask"]
    },
    "object": {
      "key": [{"prefix": "data/"}]  
    }
  }
}
EOF
}
resource "aws_cloudwatch_event_target" "trigger_step_function" {
  rule      = aws_cloudwatch_event_rule.s3_event_rule.name
  arn       = aws_sfn_state_machine.first_step_function.arn
  role_arn  = aws_iam_role.eventbridge_role.arn
}

resource "aws_iam_role" "eventbridge_role" {
  name = "eventbridge-stepfunction-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "eventbridge_step_function_policy" {
  name        = "eventbridge-stepfunction-policy"
  description = "Allows EventBridge to start Step Function execution"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "states:StartExecution"
        Resource = aws_sfn_state_machine.first_step_function.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_policy_attach" {
  policy_arn = aws_iam_policy.eventbridge_step_function_policy.arn
  role       = aws_iam_role.eventbridge_role.name
}


