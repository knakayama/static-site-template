variable "name" {
}

variable "vpc_cidr" {
}

variable "azs" {
}

variable "public_subnets" {
}

variable "ssh_cidr_blocks" {
}

module "vpc" {
  source = "./vpc"

  name = "${var.name}-vpc"
  cidr = "${var.vpc_cidr}"
}

module "public_subnet" {
  source = "./public_subnet"

  name           = "${var.name}"
  vpc_id         = "${module.vpc.id}"
  azs            = "${var.azs}"
  public_subnets = "${var.public_subnets}"
}

module "security_group" {
  source = "./security_group"

  name            = "${var.name}"
  vpc_id          = "${module.vpc.id}"
  ssh_cidr_blocks = "${var.ssh_cidr_blocks}"
}

resource "aws_network_acl" "acl" {
  vpc_id     = "${module.vpc.id}"
  subnet_ids = ["${split(",", module.public_subnet.subnet_ids)}"]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    Name = "${var.name}-nwacl"
  }
}

output "vpc_id" {
  value = "${module.vpc.id}"
}

output "public_subnet_ids" {
  value = "${module.public_subnet.subnet_ids}"
}

output "ssh_sg_id" {
  value = "${module.security_group.ssh_sg_id}"
}

output "wp_sg_id" {
  value = "${module.security_group.wp_sg_id}"
}
