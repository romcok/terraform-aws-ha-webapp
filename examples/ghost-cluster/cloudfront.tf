module cloudfront_label {
  source      = "../../modules/label"
  name        = "cloudfront"
  namespace   = local.name
  environment = local.env
  module      = "main"
  group       = "network"
}

locals {
  origin_id = "${module.cloudfront_label.id}-origin"
}

resource aws_cloudfront_distribution ghost {

  origin {
    domain_name = module.ghost_cluster.alb_dns_name
    origin_id   = local.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 80
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "CDN distribution for ${module.cloudfront_label.id}"

  # aliases = [ ]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id

    forwarded_values {
      query_string = true
      headers      = ["Host", "Set-Cookie"]

      cookies {
        forward = "all"
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400

  }
  ordered_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0

    path_pattern = "/ghost/*"
  }

  ordered_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id

    forwarded_values {
      query_string = true
      headers = [
        "Access-Control-Allow-Origin",
        "Access-Control-Request-Method",
        "Origin"
      ]

      cookies {
        forward = "none"
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0

    path_pattern = "/rss/*"
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = module.cloudfront_label.tags
}
