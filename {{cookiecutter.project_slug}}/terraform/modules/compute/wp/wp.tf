variable "name" {
  default = "wp"
}

variable "az" {
}

variable "key_name" {
}

variable "public_subnet_id" {
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

resource "aws_iam_role" "wp" {
  name               = "${var.name}"
  assume_role_policy = "${file(concat(path.module, "/", "assume_role_policy.json"))}"
}

resource "template_file" "wp" {
  template = "${file(concat(path.module, "/", "iam_role_policy.json.tpl"))}"

  vars {
    prod_bucket = "${var.prod_static_site_bucket}"
    stg_bucket  = "${var.stg_static_site_bucket}"
  }
}

resource "aws_iam_role_policy" "wp" {
  name   = "${var.name}"
  role   = "${aws_iam_role.wp.id}"
  policy = "${template_file.wp.rendered}"
}

resource "aws_iam_instance_profile" "wp" {
  name  = "${var.name}"
  roles = ["${aws_iam_role.wp.name}"]
}

resource "aws_instance" "wp" {
  instance_type               = "${var.wp_instance_type}"
  ami                         = "${var.wp_ami_id}"
  vpc_security_group_ids      = ["${concat(split(",", var.ssh_sg_id), split(",", var.wp_sg_id))}"]
  subnet_id                   = "${var.public_subnet_id}"
  key_name                    = "${var.key_name}"
  iam_instance_profile        = "${aws_iam_instance_profile.wp.id}"
  associate_public_ip_address = true

  root_block_device = {
    volume_size = "${var.wp_volume_size}"
    volume_type = "${var.wp_volume_type}"
  }

  tags {
    Name = "${var.name}-wp-1"
  }
}

resource "aws_eip" "wp" {
  instance = "${aws_instance.wp.id}"
  vpc      = true
}

output "public_ip" {
  value = "${aws_eip.wp.public_ip}"
}
