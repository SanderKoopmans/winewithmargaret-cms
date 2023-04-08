terraform {
  cloud {
    organization = "winewithmargaret"
    workspaces {
      name = "CMS"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.region
}

provider "aws" {
  region = "us-east-1"
  alias = "virginia"
}

# route 53
resource "aws_route53_zone" "winewithmargaret_zone" {
  name = var.domain_name
}

# route 53 sub API
# resource "aws_route53_record" "api_winewithmargaret" {
#   zone_id = aws_route53_zone.winewithmargaret_zone.id
#   name    = var.api_domain_name
#   type    = "A"
#   alias {
#     # name                   = "api_placeholder"
#     # zone_id                = "api_placeholder_id"
#     # evaluate_target_health = true
#     name                   = aws_cloudfront_distribution.api_dist.domain_name
#     zone_id                = aws_cloudfront_distribution.api_dist.hosted_zone_id
#     evaluate_target_health = true
#   }
# }

#  acm certificate
resource "aws_acm_certificate" "winewithmargaret_cert" {
  provider = aws.virginia
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
  tags                      = local.tags

  # lifecycle {
  #   create_before_destroy = true
  # }
}

resource "aws_route53_record" "certvalidation" {
  for_each = {
    for d in aws_acm_certificate.winewithmargaret_cert.domain_validation_options : d.domain_name => {
      name   = d.resource_record_name
      record = d.resource_record_value
      type   = d.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.winewithmargaret_zone.zone_id
}

resource "aws_acm_certificate_validation" "certvalidation" {
  depends_on = [
    aws_acm_certificate.winewithmargaret_cert
  ]
  certificate_arn         = aws_acm_certificate.winewithmargaret_cert.arn
  validation_record_fqdns = [for r in aws_route53_record.certvalidation : r.fqdn]
}

# route 53 sub CMS
resource "aws_route53_record" "cms_winewithmargaret" {
  name    = var.cms_domain_name
  zone_id = aws_route53_zone.winewithmargaret_zone.id
  type    = "A"
  alias {
    # name                   = "cms_placeholder"
    # zone_id                = "cms_placeholder_id"
    # evaluate_target_health = true
    name                   = aws_cloudfront_distribution.winewithmargaret_cms_dist.domain_name
    zone_id                = aws_cloudfront_distribution.winewithmargaret_cms_dist.hosted_zone_id
    evaluate_target_health = true
  }
}

# cloudfront
# resource "aws_cloudfront_distribution" "winewithmargaret_api_dist" {
#   enabled = true
#   aliases = [var.api_domain_name]
#   origin {
#     domain_name = aws_instance.ec2.public_dns
#     origin_id   = aws_instance.ec2.public_dns
#     # origin_access_control_id = aws_cloudfront_origin_access_control.default.id
#     custom_origin_config {
#       http_port              = 80
#       https_port             = 443
#       origin_protocol_policy = "http-only"
#       origin_ssl_protocols   = ["TLSv1.2"]
#     }
#   }
#   default_cache_behavior {
#     allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
#     cached_methods         = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id       = aws_instance.ec2.public_dns
#     viewer_protocol_policy = "redirect-to-https"
#     forwarded_values {
#       headers      = []
#       query_string = true
#       cookies {
#         forward = "all"
#       }
#     }
#   }
#   tags = local.tags
#   viewer_certificate {
#     acm_certificate_arn      = aws_acm_certificate.winewithmargaret_cert.arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2018"
#   }
# }

#  s3 media bucket

#  aws instance EC2
# resource "aws_instance" "ec2" {
#   ami           = data.aws_ami.ubuntu_ami.id
#   instance_type = "t2.micro"
#   user_data     = data.template_cloudinit_config.user_data.rendered

#   tags = merge(local.tags, {
#     Name = "ec2-cloudfront"
#   })
# }

resource "aws_s3_bucket" "cms_bucket" {
  bucket_prefix = var.bucket_prefix
  tags          = local.tags
  force_destroy = true
}

resource "aws_s3_bucket_acl" "cms_bucket_acl" {
  bucket = aws_s3_bucket.cms_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket                  = aws_s3_bucket.cms_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt" {
  bucket = aws_s3_bucket.cms_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_website_configuration" "cms_website" {
  bucket = aws_s3_bucket.cms_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "cms_bucket_policy" {
  bucket = aws_s3_bucket.cms_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy_document.json
}

resource "aws_s3_object" "object" {
  bucket       = aws_s3_bucket.cms_bucket.id
  for_each     = fileset("uploads/", "*")
  key          = "website/${each.value}"
  source       = "uploads/${each.value}"
  etag         = filemd5("uploads/${each.value}")
  content_type = "text/html"
  depends_on = [
    aws_s3_bucket.cms_bucket
  ]
}

resource "aws_cloudfront_origin_access_identity" "oai_s3_cms" {
  comment = "OAI for ${var.cms_domain_name}"
}

resource "aws_cloudfront_distribution" "winewithmargaret_cms_dist" {
  enabled             = true
  aliases             = [var.cms_domain_name]
  default_root_object = "website/index.html"
  origin {
    domain_name = aws_s3_bucket.cms_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.cms_bucket.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai_s3_cms.cloudfront_access_identity_path
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["NL"]
    }
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = aws_s3_bucket.cms_bucket.id
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      headers      = []
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }
  tags = local.tags
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.winewithmargaret_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}

#  instance SG

#  route 53 private zone for EC2
