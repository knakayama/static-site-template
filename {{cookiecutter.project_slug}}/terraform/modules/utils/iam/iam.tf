variable "name" {
  default = "iam"
}

variable "users" {
}

variable "prod_static_site_bucket" {
}

variable "stg_static_site_bucket" {
}

resource "template_file" "iam" {
  template = "${file(concat(path.module, "/", "policy.json.tpl"))}"

  vars {
    prod_bucket = "${var.prod_static_site_bucket}"
    stg_bucket  = "${var.stg_static_site_bucket}"
  }
}

resource "aws_iam_group" "iam" {
  name = "${var.name}"
}

resource "aws_iam_group_policy" "iam" {
  name   = "${var.name}"
  group  = "${aws_iam_group.iam.id}"
  policy = "${template_file.iam.rendered}"
}

resource "aws_iam_user" "iam" {
  count = "${length(split(",", var.users))}"
  name  = "${element(split(",", var.users), count.index)}"
}

resource "aws_iam_access_key" "iam" {
  count = "${length(split(",", var.users))}"
  user  = "${element(aws_iam_user.iam.*.name, count.index)}"
}

resource "aws_iam_group_membership" "iam" {
  name  = "${var.name}"
  group = "${aws_iam_group.iam.name}"
  users = ["${aws_iam_user.iam.*.name}"]
}

output "users" {
  value = "${join(",", aws_iam_access_key.iam.*.user)}"
}

output "access_ids" {
  value = "${join(",", aws_iam_access_key.iam.*.id)}"
}

output "secret_keys" {
  value = "${join(",", aws_iam_access_key.iam.*.secret)}"
}
