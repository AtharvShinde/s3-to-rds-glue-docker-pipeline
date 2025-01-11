provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = "s3-to-rds-glue-bucket"
}

resource "aws_rds_instance" "my_rds" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  name                 = "mydatabase"
  username             = "admin"
  password             = "password123"
  publicly_accessible  = true
}

resource "aws_glue_job" "my_glue" {
  name       = "my-glue-job"
  role_arn   = aws_iam_role.glue_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://path-to-script"
  }
}

resource "aws_lambda_function" "s3_to_rds_glue_lambda" {
  function_name = "s3-to-rds-glue-lambda"
  image_uri     = "010928211649.dkr.ecr.us-east-1.amazonaws.com/s3-to-rds-glue:latest"
}
