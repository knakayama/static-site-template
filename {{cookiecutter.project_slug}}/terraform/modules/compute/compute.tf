variable "name" {
}

variable "azs" {
}

variable "key_name" {
}

variable "public_subnet_ids" {
}

variable "wp_instance_type" {
}

variable "wp_volume_size" {
}

variable "wp_volume_type" {
}

variable "wp_ami_id" {
}

variable "ssh_sg_id" {
}

variable "wp_sg_id" {
}

variable "prod_static_site_bucket" {
}

variable "stg_static_site_bucket" {
}

module "wp" {
  source = "./wp"

  name                    = "${var.name}"
  az                      = "${element(split(",", var.azs), 0)}"
  key_name                = "${var.key_name}"
  public_subnet_id        = "${element(split(",", var.public_subnet_ids), 0)}"
  wp_instance_type        = "${var.wp_instance_type}"
  wp_volume_size          = "${var.wp_volume_size}"
  wp_volume_type          = "${var.wp_volume_type}"
  wp_ami_id               = "${var.wp_ami_id}"
  ssh_sg_id               = "${var.ssh_sg_id}"
  wp_sg_id                = "${var.wp_sg_id}"
  prod_static_site_bucket = "${var.prod_static_site_bucket}"
  stg_static_site_bucket  = "${var.stg_static_site_bucket}"
}

output "wp_public_ip" {
  value = "${module.wp.public_ip}"
}
