variable "name" {
  default = "dns"
}

variable "site_domain" {
}

variable "wp_domain" {
}

variable "wp_public_ip" {
}

variable "prod_static_site_domain" {
}

variable "website_domain_prod" {
}

variable "hosted_zone_id_prod" {
}

variable "stg_static_site_domain" {
}

variable "website_domain_stg" {
}

variable "hosted_zone_id_stg" {
}

variable "cloudfront_domain_name" {
}

variable "wp_domain_ttl" {
}

variable "static_site_domain" {
}

variable "static_site_domain_ttl" {
}

resource "aws_route53_zone" "dns" {
  name = "${var.site_domain}"
}

resource "aws_route53_record" "dns_wp" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.wp_domain}"
  type    = "A"
  ttl     = "${var.wp_domain_ttl}"
  records = ["${var.wp_public_ip}"]
}

resource "aws_route53_record" "dns_static_site_prod" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.prod_static_site_domain}"
  type    = "A"

  alias {
    name                   = "${var.website_domain_prod}"
    zone_id                = "${var.hosted_zone_id_prod}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "dns_static_site_stg" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.stg_static_site_domain}"
  type    = "A"

  alias {
    name                   = "${var.website_domain_stg}"
    zone_id                = "${var.hosted_zone_id_stg}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "dns_static_site_cf" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.static_site_domain}"
  type    = "CNAME"
  ttl     = "${var.static_site_domain_ttl}"
  records = ["${var.cloudfront_domain_name}"]
}

output "wp_fqdn" {
  value = "${aws_route53_record.dns_wp.fqdn}"
}

output "static_site_prod_fqdn" {
  value = "${aws_route53_record.dns_static_site_prod.fqdn}"
}

output "static_site_stg_fqdn" {
  value = "${aws_route53_record.dns_static_site_stg.fqnd}"
}

output "static_site_cloudfront_fqdn" {
  value = "${aws_route53_record.dns_static_site_cf.fqdn}"
}
