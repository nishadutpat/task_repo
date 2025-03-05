resource "aws_iam_role" "lambda_glue_role" {
  name = "lambda_glue_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy" "glue_s3_policy" {
  name        = "GlueS3AccessPolicy"
  description = "Allows Lambda to access Glue and S3"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:ListBucket", "s3:PutObject"],
        Resource = ["${aws_s3_bucket.data-buck.arn}/*", "${aws_s3_bucket.data-buck.arn}"]
      },
      {
        Effect   = "Allow",
        Action   = ["glue:BatchCreatePartition", "glue:CreateTable", "glue:UpdateTable", "glue:GetTable", "glue:CreateDatabase"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_s3_attach" {
  role       = aws_iam_role.lambda_glue_role.name
  policy_arn = aws_iam_policy.glue_s3_policy.arn
}


resource "aws_iam_policy" "lambda_vpc_access" {
  name        = "LambdaVPCPolicy"
  description = "Policy for Lambda to access VPC resources"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access_attach" {
  role       = aws_iam_role.lambda_glue_role.name
  policy_arn = aws_iam_policy.lambda_vpc_access.arn
}


resource "aws_iam_policy" "lambda_sns_policy" {
  name        = "LambdaSNSPublishPolicy"
  description = "Allows Lambda to publish to SNS"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = "arn:aws:sns:ap-south-1:703671922793:email-notifications"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sns_attach" {
  policy_arn = aws_iam_policy.lambda_sns_policy.arn
  role       = aws_iam_role.lambda_glue_role.name
}


resource "aws_iam_role" "glue_role" {
  name = "glue-crawler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "glue_policy" {
  name = "glue-crawler-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:ListBucket"],
        Resource = [
          "arn:aws:s3:::data-buck-finaltask",
          "arn:aws:s3:::data-buck-finaltask/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["glue:*"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_policy_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}


resource "aws_iam_policy" "glue_access_policy" {
  name        = "glue-access-policy"
  description = "Policy to allow Lambda to access Glue table details"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetDatabase",
          "glue:GetDatabases"
        ],
        Resource = "arn:aws:glue:ap-south-1:703671922793:catalog"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_glue_policy" {
  role       = aws_iam_role.lambda_Dynamodb_role.name
  policy_arn = aws_iam_policy.glue_access_policy.arn
}



# step function2 

resource "aws_iam_role" "step_function_2_role" {
  name = "step-function-2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "states.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "step_function_2_policy" {
  name = "StepFunction2Policy"
  description = "Allows Step Function 2 to invoke Lambda and access Glue/DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = aws_lambda_function.lambda_glue_to_dynamo.arn
      },
      {
        Effect = "Allow"
        Action = ["glue:GetTable", "glue:GetTables", "glue:GetDatabase"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = "arn:aws:dynamodb:ap-south-1:703671922793:table/TaskTable"
      },
      {
        Effect = "Allow"
        Action = "sns:Publish"
        Resource = "arn:aws:sns:ap-south-1:703671922793:email-notifications"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_function_2_policy_attach" {
  role       = aws_iam_role.step_function_2_role.name
  policy_arn = aws_iam_policy.step_function_2_policy.arn
}


resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "LambdaPolicy"
  description = "Allows Lambda to access Glue, DynamoDB, and SNS"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["glue:GetTable", "glue:GetTables", "glue:GetDatabase"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = "arn:aws:sns:ap-south-1:703671922793:email-notifications"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}


resource "aws_iam_policy" "lambda_s3_access_policy" {
  name        = "LambdaS3AccessPolicy"
  description = "Allows Lambda to read data from S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = "arn:aws:s3:::data-buck-finaltask"
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "arn:aws:s3:::data-buck-finaltask/*"
      }
    ]
  })
}


