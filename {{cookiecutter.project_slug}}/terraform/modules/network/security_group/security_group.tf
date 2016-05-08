variable "name" {
}

variable "vpc_id" {
}

variable "ssh_cidr_blocks" {
}

resource "aws_security_group" "ssh_sg" {
  name        = "${var.name}-ssh-sg"
  vpc_id      = "${var.vpc_id}"
  description = "SSH Security Group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${split(",", var.ssh_cidr_blocks)}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "wp_sg" {
  name        = "${var.name}-wp-sg"
  vpc_id      = "${var.vpc_id}"
  description = "WP Security Group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ssh_sg_id" {
  value = "${aws_security_group.ssh_sg.id}"
}

output "wp_sg_id" {
  value = "${aws_security_group.wp_sg.id}"
}
