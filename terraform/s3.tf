
resource "aws_s3_bucket" "uploads" {
  bucket = "${local.namespace}-uploads"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = aws_s3_bucket.uploads.arn
        Principal = {
          AWS = aws_iam_role.lambda.arn
        }
      }
    ]
  })
}

resource "aws_s3_bucket_notification" "uploads_notification" {
  bucket = aws_s3_bucket.uploads.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.malscanner.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket_uploads_invoke_malscanner]
}