variable "name" {
}

variable "region" {
}

variable "iam_admins" {
}

variable "site_domain" {
}

variable "static_site_sub_domain" {
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

module "iam_admin" {
  source = "../modules/utils/iam"

  name                    = "${var.name}-admin"
  users                   = "${var.iam_admins}"
  prod_static_site_bucket = "${concat("prod", ".", var.static_site_sub_domain, ".", var.site_domain)}"
  stg_static_site_bucket  = "${concat("stg", ".", var.static_site_sub_domain, ".", var.site_domain)}"
}

output "config" {
  value = <<EOT

Admin IAM:
  Admin Users: ${join("\n", formatlist("%s", split(",", module.iam_admin.users)))}
  Access IDs:  ${join("\n", formatlist("%s", split(",", module.iam_admin.access_ids)))}
  Secret Keys: ${join("\n", formatlist("%s", split(",", module.iam_admin.secret_keys)))}
EOT
}

output "iam_admin_users" {
  value = "${module.iam_admin.users}"
}

output "iam_admin_access_ids" {
  value = "${module.iam_admin.access_ids}"
}

output "iam_admin_secret_keys" {
  value = "${module.iam_admin.secret_keys}"
}

output "remote_state_bucket" {
  value = "${module.remote_state.remote_state_bucket}"
}
