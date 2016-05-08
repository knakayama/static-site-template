variable "name" {
}

variable "region" {
}

variable "site_public_key" {
}

variable "vpc_cidr" {
}

variable "azs" {
}

variable "public_subnets" {
}

variable "ssh_cidr_blocks" {
}

variable "wp_instance_type" {
}

variable "wp_volume_size" {
}

variable "wp_volume_type" {
}

variable "wp_ami_id" {
}

variable "bucket_acl" {
}

variable "site_domain" {
}

variable "wp_sub_domain" {
}

variable "static_site_sub_domain" {
}

variable "price_class" {
}

variable "wp_domain_ttl" {
}

variable "static_site_domain_ttl" {
}

variable "stg_source_ip" {
}

variable "remote_state_bucket" {
}

provider "aws" {
  region = "${var.region}"
}

module "remote_state" {
  source = "../modules/utils/remote_state"

  region              = "${var.region}"
  remote_state_bucket = "${var.remote_state_bucket}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${var.site_public_key}"
}

module "network" {
  source = "../modules/network"

  name            = "${var.name}"
  vpc_cidr        = "${var.vpc_cidr}"
  azs             = "${var.azs}"
  public_subnets  = "${var.public_subnets}"
  ssh_cidr_blocks = "${var.ssh_cidr_blocks}"
}

module "compute" {
  source = "../modules/compute"

  name                    = "${var.name}"
  azs                     = "${var.azs}"
  key_name                = "${aws_key_pair.site_key.key_name}"
  public_subnet_ids       = "${module.network.public_subnet_ids}"
  ssh_sg_id               = "${module.network.ssh_sg_id}"
  wp_sg_id                = "${module.network.wp_sg_id}"
  wp_instance_type        = "${var.wp_instance_type}"
  wp_volume_size          = "${var.wp_volume_size}"
  wp_volume_type          = "${var.wp_volume_type}"
  wp_ami_id               = "${var.wp_ami_id}"
  prod_static_site_bucket = "${concat("prod", ".", var.static_site_sub_domain, ".", var.site_domain)}"
  stg_static_site_bucket  = "${concat("stg", ".", var.static_site_sub_domain, ".", var.site_domain)}"
}

module "static_site" {
  source = "../modules/utils/static_site"

  name                    = "${var.name}"
  prod_static_site_bucket = "${concat("prod", ".", var.static_site_sub_domain, ".", var.site_domain)}"
  stg_static_site_bucket  = "${concat("stg", ".", var.static_site_sub_domain, ".", var.site_domain)}"
  stg_source_ip           = "${var.stg_source_ip}"
  bucket_acl              = "${var.bucket_acl}"
  price_class             = "${var.price_class}"
}

module "dns" {
  source = "../modules/utils/dns"

  name                    = "${var.name}"
  site_domain             = "${concat(var.site_domain, ".")}"
  wp_domain               = "${concat(var.wp_sub_domain, ".", var.site_domain, ".")}"
  wp_public_ip            = "${module.compute.wp_public_ip}"
  prod_static_site_domain = "${concat("prod", ".", var.static_site_sub_domain, ".", var.site_domain, ".")}"
  website_domain_prod     = "${module.static_site.website_domain_prod}"
  hosted_zone_id_prod     = "${module.static_site.hosted_zone_id_prod}"
  stg_static_site_domain  = "${concat("stg", ".", var.static_site_sub_domain, ".", var.site_domain, ".")}"
  website_domain_stg      = "${module.static_site.website_domain_stg}"
  hosted_zone_id_stg      = "${module.static_site.hosted_zone_id_stg}"
  cloudfront_domain_name  = "${module.static_site.cloudfront_domain_name}"
  wp_domain_ttl           = "${var.wp_domain_ttl}"
  static_site_domain      = "${concat(var.static_site_sub_domain, ".", var.site_domain, ".")}"
  static_site_domain_ttl  = "${var.static_site_domain_ttl}"
}

output "wp_public_ip" {
  value = "${module.compute.wp_public_ip}"
}

output "wp_fqdn" {
  value = "${module.dns.wp_fqdn}"
}

output "website_endpoint_prod" {
  value = "${module.static_site.website_endpoint_prod}"
}

output "website_endpoint_stg" {
  value = "${module.static_site.website_endpoint_stg}"
}

output "static_site_prod_fqdn" {
  value = "${module.dns.static_site_prod_fqdn}"
}

output "static_site_stg_fqdn" {
  value = "${module.dns.static_site_stg_fqdn}"
}

output "static_site_cloudfront_fqdn" {
  value = "${module.dns.static_site_cloudfront_fqdn}"
}

output "cloudfront_domain_name" {
  value = "${module.static_site.cloudfront_domain_name}"
}

output "remote_state_bucket" {
  value = "${module.remote_state.remote_state_bucket}"
}
