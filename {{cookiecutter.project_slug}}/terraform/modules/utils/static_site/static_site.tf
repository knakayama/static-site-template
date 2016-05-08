variable "name" {
  default = "static_site"
}

variable "prod_static_site_bucket" {
}

variable "stg_static_site_bucket" {
}

variable "bucket_acl" {
}

variable "stg_source_ip" {
}

variable "price_class" {
}

resource "aws_cloudfront_origin_access_identity" "static_site" {
  comment = "${var.name}"
}

resource "template_file" "static_site_prod" {
  template = "${file(concat(path.module, "/", "prod_bucket_policy.json.tpl"))}"

  vars {
    prod_bucket            = "${var.prod_static_site_bucket}"
    origin_access_identity = "${aws_cloudfront_origin_access_identity.static_site.id}"
  }
}

resource "template_file" "static_site_stg" {
  template = "${file(concat(path.module, "/", "stg_bucket_policy.json.tpl"))}"

  vars {
    stg_bucket    = "${var.stg_static_site_bucket}"
    stg_source_ip = "${var.stg_source_ip}"
  }
}

resource "aws_s3_bucket" "static_site_prod" {
  bucket        = "${var.prod_static_site_bucket}"
  acl           = "${var.bucket_acl}"
  policy        = "${template_file.static_site_prod.rendered}"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket" "static_site_stg" {
  bucket        = "${var.stg_static_site_bucket}"
  acl           = "${var.bucket_acl}"
  policy        = "${template_file.static_site_stg.rendered}"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_cloudfront_distribution" "static_site" {
  enabled             = true
  comment             = "${var.name}"
  default_root_object = "index.html"
  price_class         = "${var.price_class}"
  retain_on_delete    = true

  origin {
    domain_name = "${concat(aws_s3_bucket.static_site_prod.id, ".s3.amazonaws.com")}"
    origin_id   = "${aws_s3_bucket.static_site_prod.id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.static_site.cloudfront_access_identity_path}"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.static_site_prod.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
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
    cloudfront_default_certificate = true
  }
}

output "website_endpoint_prod" {
  value = "${aws_s3_bucket.static_site_prod.website_endpoint}"
}

output "website_domain_prod" {
  value = "${aws_s3_bucket.static_site_prod.website_domain}"
}

output "hosted_zone_id_prod" {
  value = "${aws_s3_bucket.static_site_prod.hosted_zone_id}"
}

output "website_endpoint_stg" {
  value = "${aws_s3_bucket.static_site_stg.website_endpoint}"
}

output "website_domain_stg" {
  value = "${aws_s3_bucket.static_site_stg.website_domain}"
}

output "hosted_zone_id_stg" {
  value = "${aws_s3_bucket.static_site_stg.hosted_zone_id}"
}

output "cloudfront_domain_name" {
  value = "${aws_cloudfront_distribution.static_site.domain_name}"
}
