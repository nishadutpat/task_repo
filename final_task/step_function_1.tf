resource "aws_sfn_state_machine" "first_step_function" {
  name     = "first-step-function"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment = "First Step Function to process S3 file and insert into Glue Table"
    StartAt = "ProcessFile"
    States = {
      ProcessFile = {
        Type     = "Task"
        Resource = aws_lambda_function.lambda_glue_insert.arn
        Next     = "TriggerStepFunction2"
      },
      TriggerStepFunction2 = {
        Type     = "Task"
        Resource = "arn:aws:states:::states:startExecution"
        Parameters = {
          StateMachineArn = "arn:aws:states:ap-south-1:703671922793:stateMachine:second-step-function"
        }
        End = true
      }
    }
  })
}



resource "aws_iam_role" "step_function_role" {
  name = "step-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })
}


resource "aws_iam_policy" "step_function_lambda_policy" {
  name        = "StepFunctionLambdaPolicy"
  description = "Allows Step Function 1 to invoke Lambda and start Step Function 2"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "lambda:InvokeFunction",
        Resource = aws_lambda_function.lambda_glue_insert.arn
      },
      {
        Effect   = "Allow",
        Action   = "states:StartExecution",
        Resource = "arn:aws:states:ap-south-1:703671922793:stateMachine:second-step-function"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "step_function_policy_attach" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_lambda_policy.arn
}



resource "aws_iam_role_policy_attachment" "step_function_lambda_policy_attach" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_lambda_policy.arn
}




# step  fucntion 2

resource "aws_sfn_state_machine" "second_step_function" {
  name     = "second-step-function"
  role_arn = aws_iam_role.step_function_2_role.arn

  definition = jsonencode({
    Comment = "Step Function 2 to process Glue data, update DynamoDB, and send notification"
    StartAt = "ProcessGlueData"
    States = {
      ProcessGlueData = {
        Type     = "Task"
        Resource = aws_lambda_function.lambda_glue_to_dynamo.arn
        End      = true
      }
    }
  })
}


resource "aws_iam_policy" "step_function_invoke_policy" {
  name        = "StepFunctionInvokePolicy"
  description = "Allows Step Function 1 to start Step Function 2"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "states:StartExecution",
        Resource = "arn:aws:states:ap-south-1:703671922793:stateMachine:second-step-function"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_function_role_attachment" {
  role       = "step-function-role"
  policy_arn = aws_iam_policy.step_function_invoke_policy.arn
}
