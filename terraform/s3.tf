
resource "aws_s3_bucket" "bucket_logs" {
  bucket = "${local.namespace}-bucket-logs"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "uploads" {
  bucket = "${local.namespace}-uploads"
  acl    = "private"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
  }

  logging {
    target_bucket = aws_s3_bucket.bucket_logs.id
    target_prefix = "${local.namespace}-uploads/"
  }

  versioning {
    enabled = false
  }

  lifecycle_rule {
    enabled = true
    expiration {
      days = 14
    }
  }
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