terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}
##############################################
provider "aws" {
  region = "us-east-1"
}
###############################################
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
}

##############################################
resource "aws_s3_object" "home_html" {
  bucket        = aws_s3_bucket.website_bucket.id
  key           = "home/home.html" # Path in the bucket
  source        = "resume/home/home.html" # Local file path
  etag          = filemd5("resume/home/home.html") #updates files
  content_type  = "text/html" # Correct MIME type
}

resource "aws_s3_object" "home_css" {
  bucket        = aws_s3_bucket.website_bucket.id
  key           = "home.css"
  source        = "resume/home.css"
  content_type  = "text/css" # Correct MIME type
}

resource "aws_s3_object" "home_js" {
  bucket        = aws_s3_bucket.website_bucket.id
  key           = "home.js"
  source        = "resume/home.js"
  content_type  = "application/javascript" # Correct MIME type
}
##############################################
resource "aws_s3_object" "aboutme_html" {
  bucket        = aws_s3_bucket.website_bucket.id
  key           = "aboutme/aboutme.html" # Path in the bucket
  source        = "resume/aboutme/aboutme.html" # Local file path
  content_type  = "text/html" # Correct MIME type
}

resource "aws_s3_object" "aboutme_css" {
  bucket        = aws_s3_bucket.website_bucket.id
  key           = "aboutme/aboutme.css" # Path in the bucket
  source        = "resume/aboutme/aboutme.css" # Local file path
  content_type  = "text/css" # Correct MIME type
}

resource "aws_s3_object" "aboutme_js" {
  bucket        = aws_s3_bucket.website_bucket.id
  key           = "aboutme/aboutme.js" # Path in the bucket
  source        = "resume/aboutme/aboutme.js" # Local file path
  content_type  = "application/js" # Correct MIME type
}
##############################################
resource "aws_s3_object" "projects_html" {
  bucket        = aws_s3_bucket.website_bucket.id
  key           = "projects/projects.html" # Path in the bucket
  source        = "resume/projects/projects.html" # Local file path
  content_type  = "text/html" # Correct MIME type
}

resource "aws_s3_object" "projects_css" {
  bucket        = aws_s3_bucket.website_bucket.id
  key           = "projects/projects.css" # Path in the bucket
  source        = "resume/projects/projects.css" # Local file path
  content_type  = "text/css" # Correct MIME type
}

resource "aws_s3_object" "projects_js" {
  bucket        = aws_s3_bucket.website_bucket.id
  key           = "projects/projects.js" # Path in the bucket
  source        = "resume/projects/projects.js" # Local file path
  content_type  = "application/javascript" # Correct MIME type
}
##############################################
resource "aws_s3_object" "resume_html" {
  bucket        = aws_s3_bucket.website_bucket.id
  key           = "resume/resume.html" # Path in the bucket
  source        = "resume/resume/resume.html" # Local file path
  content_type  = "text/html" # Correct MIME type
}

resource "aws_s3_object" "resume_css" {
  bucket        = aws_s3_bucket.website_bucket.id
  key           = "resume/resume.css" # Path in the bucket
  source        = "resume/resume/resume.css" # Local file path
  content_type  = "text/css" # Correct MIME type
}

resource "aws_s3_object" "resume_js" {
  bucket        = aws_s3_bucket.website_bucket.id
  key           = "resume/resume.js" # Path in the bucket
  source        = "resume/resume/resume.js" # Local file path
  content_type  = "application/javascript" # Correct MIME type
}
####################################################
resource "aws_s3_bucket_website_configuration" "entry" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}
####################################################
resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.website_bucket.id
  key = "index.html"
  source = "resume/index.html"
  etag = filemd5("resume/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "pindex_html" {
  bucket = aws_s3_bucket.website_bucket.id
  key = "pindex.html"
  source = "resume/pindex.html"
  etag = filemd5("resume/pindex.html")
  content_type = "text/html"
}

resource "aws_s3_object" "aindex_html" {
  bucket = aws_s3_bucket.website_bucket.id
  key = "aindex.html"
  source = "resume/aindex.html"
  etag = filemd5("resume/aindex.html")
  content_type = "text/html"
}

resource "aws_s3_object" "rindex_html" {
  bucket = aws_s3_bucket.website_bucket.id
  key = "rindex.html"
  source = "resume/rindex.html"
  etag = filemd5("resume/rindex.html")
  content_type = "text/html"
}
######################################################
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin Access Identity for CloudFront Distribution"
}
#######################################################
resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id = var.bucket_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html" 

  aliases = ["charle8.com"]  # Add your domain here

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods =  ["GET", "HEAD"]
    target_origin_id = var.bucket_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  viewer_certificate {    #Changed from cloudfront default certificate to custom ie. below
  acm_certificate_arn = aws_acm_certificate.charle8_cert.arn
  ssl_support_method = "sni-only"
}

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  tags = {
    Name = "Cloudfront Distribution"
    Environment = "Pro"
  }

}
##########################################################
resource "aws_s3_bucket_policy" "website_bucket_policy" { #Allow cloudfront access to s3 buckets
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
  Version = "2012-10-17",
  Statement = [
    {
      Action = "s3:GetObject",
      Effect = "Allow",
      Resource = "${aws_s3_bucket.website_bucket.arn}/*",
      Principal = {
        CanonicalUser = "${aws_cloudfront_origin_access_identity.origin_access_identity.s3_canonical_user_id}"
      }
    }
  ]
})
}
###########################################################
#Blockallpublicaccess block
resource "aws_s3_bucket_public_access_block" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}