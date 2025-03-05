
resource "aws_lambda_function" "lambda_glue_insert" {
  function_name = "lambda-glue-insert"
  role          = aws_iam_role.lambda_glue_role.arn
  package_type  = "Image"
  image_uri     = "703671922793.dkr.ecr.ap-south-1.amazonaws.com/glue_repo:latest"
  timeout       = 60
  /*vpc_config {
    subnet_ids         = ["subnet-0153bd412dda5847f", "subnet-02f0e236b1390e48d"]  # Replace with your subnet IDs
    security_group_ids = ["sg-025812e0d2825aaf0"]  # Replace with your security group ID
  }*/
  environment {
    variables = {
      S3_BUCKET  = aws_s3_bucket.data-buck.bucket
      GLUE_DB    = aws_glue_catalog_database.emp_detail.name
 
    }
  }
}

# step fucntion 2
resource "aws_lambda_function" "lambda_glue_to_dynamo" {
  function_name = "lambda-glue-to-dynamo"
  role          = aws_iam_role.lambda_execution_role.arn
  package_type  = "Image"
  image_uri     = "703671922793.dkr.ecr.ap-south-1.amazonaws.com/lf2_repo:latest"
  timeout       = 60  
  /*handler       = "lambda_glue_to_dynamodb.lambda_handler"
  runtime       = "python3.9"*/
  

  environment {
    variables = {
      GLUE_DATABASE = "emp_detail"
      GLUE_TABLE    = "emp_tabledata"
      DYNAMO_TABLE  = "TaskTable"
      SNS_TOPIC_ARN = "arn:aws:sns:ap-south-1:703671922793:email-notifications"  
    }
  }

 /* filename = "lambda_glue_to_dynamodb.zip"*/
}

