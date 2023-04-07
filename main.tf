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

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-1"
}

# route 53
resource "aws_route53_zone" "winewithmargaret_zone" {
  name = "winewithmargaret.com"
}

# route 53 sub CMS
resource "aws_route53_record" "cms_winewithmargaret" {
  zone_id = aws_route53_zone.winewithmargaret_zone.id
  name    = "cms.winewithmargaret.com"
  type    = "A"
  alias {
    name                   = "cms_placeholder"
    zone_id                = "cms_placeholder_id"
    evaluate_target_health = true
    # name                   = aws_cloudfront_distribution.winewithmargaret_cms_dist.domain_name
    # zone_id                = aws_cloudfront_distribution.winewithmargaret_cms_dist.hosted_zone_id
    # evaluate_target_health = true
  }
}

# route 53 sub API
resource "aws_route53_record" "api_winewithmargaret" {
  zone_id = aws_route53_zone.winewithmargaret_zone.id
  name    = "api.winewithmargaret.com"
  type    = "A"
  alias {
    name                   = "api_placeholder"
    zone_id                = "api_placeholder_id"
    evaluate_target_health = true
    # name                   = aws_cloudfront_distribution.api_dist.domain_name
    # zone_id                = aws_cloudfront_distribution.api_dist.hosted_zone_id
    # evaluate_target_health = true
  }
}

#  acm certificate
resource "aws_acm_certificate" "winewithmargaret_cert" {
  domain_name       = "winewithmargaret.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  # dns_validation {
  #   hosted_zone_id = aws_route53_zone.winewithmargaret_zone.zone_id
  #   record_name    = "_acme-challenge.winewithmargaret.com"
  # }
}

# cloudfront
# resource "aws_cloudfront_distribution" "winewithmargaret_cms_dist" {
#   origin {
#     domain_name              = aws_s3_bucket.b.bucket_regional_domain_name
#     origin_access_control_id = aws_cloudfront_origin_access_control.default.id
#     origin_id                = local.s3_origin_id
#   }
# }

#  s3 media bucket

#  aws instance EC2 + docker

#  instance SG

#  route 53 private zone for EC2
