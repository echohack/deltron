

resource "aws_security_group" "chef_server" {
  name        = "chef_server_${random_id.automate_instance_id.hex}"
  description = "Terraform Automate Chef Server"
  vpc_id      = "${var.automate_vpc}"

  tags {
    Name = "${var.automate_tag}_chef_server_security_group"
    X-Dept    = "${var.tag_dept}"
    X-Contact = "${var.tag_contact}"
  }
}

# SSH - all
resource "aws_security_group_rule" "ingress_chef_server_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_server.id}"
}

# HTTP (nginx)
resource "aws_security_group_rule" "ingress_chef_server_allow_80_tcp" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_server.id}"
}

# HTTPS (nginx)
resource "aws_security_group_rule" "ingress_chef_server_allow_443_tcp" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_server.id}"
}

# opscode push-jobs
resource "aws_security_group_rule" "ingress_chef_server_allow_10000-10003_tcp" {
  type = "ingress"
  from_port = 10000
  to_port = 10003
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_server.id}"
}

# Allow all Chef
resource "aws_security_group_rule" "ingress_chef_server_allow_all_chef_automate" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef_automate.id}"
  security_group_id = "${aws_security_group.chef_server.id}"
}

# Egress: ALL
resource "aws_security_group_rule" "egress_chef_server_allow_0-65535_all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_server.id}"
}

resource "aws_security_group" "chef_automate" {
  name        = "chef_automate_${random_id.automate_instance_id.hex}"
  description = "Terraform Chef Automate Server"
  vpc_id      = "${var.automate_vpc}"

  tags {
    Name = "${var.automate_tag}_chef_automate_security_group"
    X-Dept    = "${var.tag_dept}"
    X-Contact = "${var.tag_contact}"
  }
}

# SSH - all
resource "aws_security_group_rule" "ingress_chef_automate_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_automate.id}"
}

# HTTP
resource "aws_security_group_rule" "ingress_chef_automate_allow_80_tcp" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_automate.id}"
}

# HTTPS
resource "aws_security_group_rule" "ingress_chef_automate_allow_443_tcp" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_automate.id}"
}

# Automate GIT
resource "aws_security_group_rule" "ingress_chef_automate_allow_8989_tcp" {
  type = "ingress"
  from_port = 8989
  to_port = 8989
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_automate.id}"
}

# Allow all Chef Server
resource "aws_security_group_rule" "ingress_chef_automate_allow_all_chef_server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef_server.id}"
  security_group_id = "${aws_security_group.chef_automate.id}"
}

# Egress: ALL
resource "aws_security_group_rule" "egress_chef_automate_allow_0-65535_all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_automate.id}"
}

resource "aws_security_group" "build_nodes" {
  name        = "build_nodes_${random_id.automate_instance_id.hex}"
  description = "Terraform Build Nodes"
  vpc_id      = "${var.automate_vpc}"

  tags {
    Name = "${var.automate_tag}_build_nodes_security_group"
    X-Dept    = "${var.tag_dept}"
    X-Contact = "${var.tag_contact}"
  }
}

# Egress: ALL
resource "aws_security_group_rule" "egress_build_nodes_allow_0-65535_all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.build_nodes.id}"
}

# SSH - all
resource "aws_security_group_rule" "ingress_build_nodes_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.build_nodes.id}"
}

# Allow all Chef Automate
resource "aws_security_group_rule" "ingress_build_nodes_allow_all_chef_server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef_automate.id}"
  security_group_id = "${aws_security_group.build_nodes.id}"
}
