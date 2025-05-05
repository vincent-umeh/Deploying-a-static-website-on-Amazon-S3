provider "aws" {
  region = var.aws_region
}

#create S3 bucket
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
  tags = var.tags
}

#configure static website hosting
resource "aws_s3_bucket_website_configuration" "website_configuretion" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

#enable public access to the bucket
resource "aws_s3_bucket_public_access_block" "website_bucket_public_access" {
  bucket = aws_s3_bucket.website_bucket.id
    depends_on = [ aws_s3_bucket.website_bucket ]

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  depends_on = [ aws_s3_bucket_public_access_block.website_bucket_public_access ]

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "${aws_s3_bucket.website_bucket.arn}/*"
            ]
        }
    ]
}
POLICY
}

#upload website files to S3 bucket
resource "aws_s3_object" "website_assets" {
  for_each     = fileset(var.website_path, "**/*")
  bucket       = aws_s3_bucket.website_bucket.id
  key          = each.value
  source       = "${var.website_path}/${each.value}"
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
  etag         = filemd5("${var.website_path}/${each.value}")
}


#upload image to S3 bucket
resource "aws_s3_object" "upload_images" {
  for_each     = fileset("${path.module}/images", "*.{jpg,jpeg,png,gif,webp,svg,ico}")
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "images/${each.value}"  # Uploads to 'images/' folder in S3
  source       = "${path.module}/images/${each.value}"
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
  etag         = filemd5("${path.module}/images/${each.value}")
  #cache_control = "max-age=31536000, public"
}



locals {
  mime_types = {
    "html" = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript",
    "png"  = "image/png",
    "jpg"  = "image/jpeg"
  }
}

#print bucket endpoint
output "bucket_endpoint" {
  value = aws_s3_bucket.website_bucket.website_endpoint
  
}


#############Create CloudFront distribution######################
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.website_bucket.id}"
    

    # Required for S3 origin when using OAI (even if not using in this case)
    s3_origin_config {
      origin_access_identity = "" # Leave empty for public bucket access
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for S3 bucket"
  default_root_object = "index.html"

  # Default cache behavior
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website_bucket.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all" # Allows both HTTP and HTTPS
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }


  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true # Uses default CF certificate
  }


  # Wait for the distribution to be deployed
  wait_for_deployment = true
}

#output CloudFront distribution domain name
output "name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
  description = "CloudFront distribution domain name"
}