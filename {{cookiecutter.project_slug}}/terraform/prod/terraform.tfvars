# General
name = "prod-static-site-template"

region = "{{ cookiecutter.region }}"

# Network
vpc_cidr = "10.0.0.0/24"

azs = "{{ cookiecutter.region }}a"

public_subnets = "10.0.0.0/24"

ssh_cidr_blocks = "{{ cookiecutter.ssh_cidr_blocks }}"

# Compute
wp_instance_type = "{{ cookiecutter.wp_instance_type }}"

wp_volume_size = "{{ cookiecutter.wp_volume_size }}"

wp_volume_type = "{{ cookiecutter.wp_volume_type }}"

# S3
bucket_acl = "public-read"

stg_source_ip = "{{ cookiecutter.stg_source_ip }}"

# CloudFront
price_class = "{{ cookiecutter.cloudfront_price_class }}"

# Route53
site_domain = "{{ cookiecutter.site_domain.rstrip('.') }}"

wp_sub_domain = "{{ cookiecutter.wp_sub_domain }}"

static_site_sub_domain = "{{ cookiecutter.static_site_sub_domain }}"

wp_domain_ttl = "{{ cookiecutter.wp_domain_ttl }}"

static_site_domain_ttl = "{{ cookiecutter.static_site_domain_ttl }}"
