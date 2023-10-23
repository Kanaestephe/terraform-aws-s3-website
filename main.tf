# Create S3 Bucket resource
resource "aws_s3_bucket" "demo_bucket" {
  bucket = var.bucket_name
  tags          = var.tags
  force_destroy = true
}

# Configure bucket acl
resource "aws_s3_bucket_ownership_controls" "demo_bucket" {
  bucket = aws_s3_bucket.demo_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_public_access_block" "demo_bucket" {
  bucket = aws_s3_bucket.demo_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "demo_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.demo_bucket,
    aws_s3_bucket_public_access_block.demo_bucket,
  ]

  bucket = aws_s3_bucket.demo_bucket.id
  acl    = "public-read"
}

# Configure bucket policy
resource "aws_s3_bucket_policy" "demo_bucket_policy" {
  bucket = aws_s3_bucket.demo_bucket.id
  policy = data.aws_iam_policy_document.allow_everyone.json
}

data "aws_iam_policy_document" "allow_everyone" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:GetObject",]

    resources = [
      aws_s3_bucket.demo_bucket.arn,
      "${aws_s3_bucket.demo_bucket.arn}/*",
    ]
  }
}

# Define website configuration 
resource "aws_s3_bucket_website_configuration" "demo_bucket_webssite" {
  bucket = aws_s3_bucket.demo_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
