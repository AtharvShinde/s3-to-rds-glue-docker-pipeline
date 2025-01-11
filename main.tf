provider "aws" {
  region = "us-east-1"
}

# Create an S3 bucket
resource "aws_s3_bucket" "data_bucket" {
  bucket = "s3-to-rds-glue-bucket"
}

# Create an RDS MySQL instance
resource "aws_db_instance" "my_rds" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  name                 = "mydatabase"
  username             = "admin"
  password             = "password123"
  publicly_accessible  = true
  skip_final_snapshot  = true
}

# Create an IAM Role for Glue job
resource "aws_iam_role" "glue_role" {
  name = "glue-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

# Create a Glue job
resource "aws_glue_job" "my_glue" {
  name       = "my-glue-job"
  role_arn   = aws_iam_role.glue_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://path-to-script"
  }
}

# Create the Lambda function
resource "aws_lambda_function" "s3_to_rds_glue_lambda" {
  function_name = "s3-to-rds-glue-lambda"
  image_uri     = "010928211649.dkr.ecr.us-east-1.amazonaws.com/s3-to-rds-glue:latest"
  
  # IAM Role for Lambda function
  role = aws_iam_role.lambda_exec_role.arn
}

# Create IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-execution-role"
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
