provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region     = "${var.aws_default_region}"
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = "${var.automate_vpc}"
  route_table_id = "${var.automate_route_table_id}"
}

resource "aws_subnet" "automate_subnet" {
  vpc_id                  = "${var.automate_vpc}"
  cidr_block              = "33.33.34.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.automate_tag}_subnet"
  }
}

resource "aws_route_table_association" "automate_public_routing" {
  subnet_id      = "${aws_subnet.automate_subnet.id}"
  route_table_id = "${var.automate_route_table_id}"
}

resource "aws_security_group" "chef_server" {
  name        = "chef_server"
  description = "Terraform Automate Chef Server"
  vpc_id      = "${var.automate_vpc}"

  tags {
    Name = "${var.automate_tag}_chef_server_security_group"
  }
}

# SSH - all
resource "aws_security_group_rule" "chef_server_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_server.id}"
}

# HTTP (nginx)
resource "aws_security_group_rule" "chef_server_allow_80_tcp" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_server.id}"
}

# HTTPS (nbinx)
resource "aws_security_group_rule" "chef_server_allow_443_tcp" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_server.id}"
}

# oc_bifrost
resource "aws_security_group_rule" "chef_server_allow_9463_tcp" {
  type = "ingress"
  from_port = 9463
  to_port = 9463
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_server.id}"
}

# oc_bifrost (nginx LB)
resource "aws_security_group_rule" "chef_server_allow_9683_tcp" {
  type = "ingress"
  from_port = 9683
  to_port = 9683
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_server.id}"
}

# opscode push-jobs
resource "aws_security_group_rule" "chef_server_allow_10000-10003_tcp" {
  type = "ingress"
  from_port = 10000
  to_port = 10003
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_server.id}"
}

# Allow all Chef 
resource "aws_security_group_rule" "chef_server_allow_all_chef_automate" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef_automate.id}"
  security_group_id = "${aws_security_group.chef_server.id}"
}

# Egress: ALL
resource "aws_security_group_rule" "chef_server_allow_0-65535_all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_server.id}"
}

resource "aws_security_group" "chef_automate" {
  name        = "chef_automate"
  description = "Terraform Chef Automate Server"
  vpc_id      = "${var.automate_vpc}"

  tags {
    Name = "${var.automate_tag}_chef_automate_security_group"
  }
}

# SSH - all
resource "aws_security_group_rule" "chef_automate_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_automate.id}"
}

# HTTP
resource "aws_security_group_rule" "chef_automate_allow_80_tcp" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_automate.id}"
}

# HTTPS
resource "aws_security_group_rule" "chef_automate_allow_443_tcp" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_automate.id}"
}

# Automate GIT
resource "aws_security_group_rule" "chef_automate_allow_8989_tcp" {
  type = "ingress"
  from_port = 8989
  to_port = 8989
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_automate.id}"
}

# Allow all Chef Server
resource "aws_security_group_rule" "chef_automate_allow_all_chef_server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef_server.id}"
  security_group_id = "${aws_security_group.chef_automate.id}"
}

# Egress: ALL
resource "aws_security_group_rule" "chef_automate_allow_0-65535_all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_automate.id}"
}

resource "aws_instance" "chef_server" {
  connection {
    user     = "${var.aws_ami_user}"
    key_file = ".keys/${var.aws_key_pair_name}.pem"
  }

  ami             = "${var.aws_ami_rhel}"
  instance_type   = "${var.aws_instance_type}"
  key_name        = "${var.aws_key_pair_name}"
  subnet_id       = "${aws_subnet.automate_subnet.id}"
  security_groups = ["${aws_security_group.chef_server.id}"]

  tags {
    Name      = "${format("${var.automate_tag}_chef_server_%02d", count.index + 1)}"
    X-Project = "CSE"
  }

  provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname ${aws_instance.chef_server.public_dns}"]
  }

  provisioner "file" {
    source      = "chef_server.sh"
    destination = "~/chef_server.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/chef_server.sh",
      "~/chef_server.sh",
    ]
  }

  provisioner "local-exec" {
    command = "scp -oStrictHostKeyChecking=no -i .keys/${var.aws_key_pair_name}.pem ${var.aws_ami_user}@${aws_instance.chef_server.public_dns}:~/chef_automate.pem .keys"
  }

  provisioner "local-exec" {
    command = "scp -oStrictHostKeyChecking=no -i .keys/${var.aws_key_pair_name}.pem ${var.aws_ami_user}@${aws_instance.chef_server.public_dns}:~/delivery-validator.pem .keys"
  }
}

resource "aws_instance" "chef_automate" {
  connection {
    user     = "${var.aws_ami_user}"
    key_file = ".keys/${var.aws_key_pair_name}.pem"
  }

  ami             = "${var.aws_ami_rhel}"
  instance_type   = "${var.aws_instance_type}"
  key_name        = "${var.aws_key_pair_name}"
  subnet_id       = "${aws_subnet.automate_subnet.id}"
  security_groups = ["${aws_security_group.chef_automate.id}"]

  tags {
    Name      = "${format("${var.automate_tag}_chef_automate_%02d", count.index + 1)}"
    X-Project = "CSE"
  }

  provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname ${aws_instance.chef_automate.public_dns}"]
  }

  provisioner "file" {
    source      = "chef_automate.license"
    destination = "~/chef_automate.license"
  }

  provisioner "file" {
    source      = ".keys/chef_automate.pem"
    destination = "~/chef_automate.pem"
  }
}

data "template_file" "chef_automate_sh" {
  template = "${file("./chef_automate.tpl")}"
  vars {    
    chef_automate_user_key = "~/chef_automate.pem"
    chef_server_public_dns = "${aws_instance.chef_server.public_dns}"
    chef_automate_org = "delivery"
    chef_automate_public_dns = "${aws_instance.chef_automate.public_dns}"
    enterprise_name = "myface"
  }
}


# looking for a way to get around circular dependency with rendering template on chef_automate server while knowing public_dns....?
resource "null_resource" "chef_automate_install" {

  connection {
    host = "${aws_instance.chef_automate.public_ip}"
    user     = "${var.aws_ami_user}"
    key_file = ".keys/${var.aws_key_pair_name}.pem"
  }

  provisioner "file" {
    content      = "${data.template_file.chef_automate_sh.rendered}"
    destination = "~/chef_automate.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/chef_automate.sh",
      "~/chef_automate.sh",
    ]
  }
}
