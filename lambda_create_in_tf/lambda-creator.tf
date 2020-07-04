provider "aws" {
  region     = "us-east-1"
}

resource "aws_lambda_function" "job1" {
  filename         = "stop_instance.zip"
  source_code_hash = filebase64sha256("stop_instance.zip")
  function_name    = "job1"
  role             = "arn:aws:iam::440414308601:role/lambda_role"
  handler          = "stop_instance.lambda_handler"
  runtime          = "python3.8"
  timeout          = "900"
  environment {
    variables = {
      S3_BUCKET = "akmana"
    }
  }
}

