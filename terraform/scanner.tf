resource "aws_ecr_repository" "malscanner" {
  name                 = local.malscanner
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_ecr_image" "malscanner" {
  repository_name = aws_ecr_repository.malscanner.name
  image_tag       = "latest"
}

resource "aws_lambda_function" "malscanner" {
  description   = "Malware scanner for ${local.namespace}"
  function_name = local.malscanner
  role          = aws_iam_role.lambda.arn
  memory_size   = var.function_memory_mb
  timeout       = 180
  image_uri     = "${aws_ecr_repository.malscanner.repository_url}@${data.aws_ecr_image.malscanner.id}"
  package_type  = "Image"

  environment {
    variables = {
      NODE_ENV      = var.target_env
      AWS_S3_BUCKET = aws_s3_bucket.uploads.bucket
      AWS_S3_REGION = var.region
    }
  }
}


resource "aws_lambda_permission" "allow_bucket_uploads_invoke_malscanner" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.malscanner.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.uploads.arn
}