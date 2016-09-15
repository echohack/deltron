provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region     = "${var.aws_default_region}"
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = "${var.automate_vpc}"
  route_table_id = "${var.automate_route_table_id}"
}

resource "aws_route_table_association" "automate_public_routing" {
  subnet_id      = "${var.automate_subnet}"
  route_table_id = "${var.automate_route_table_id}"
}

resource "aws_security_group" "chef_server" {
  name        = "chef_server_${var.automate_instance_id}"
  description = "Terraform Automate Chef Server"
  vpc_id      = "${var.automate_vpc}"

  tags {
    Name = "${var.automate_tag}_chef_server_security_group"
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

# HTTPS (nbinx)
resource "aws_security_group_rule" "ingress_chef_server_allow_443_tcp" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_server.id}"
}

# oc_bifrost
resource "aws_security_group_rule" "ingress_chef_server_allow_9463_tcp" {
  type = "ingress"
  from_port = 9463
  to_port = 9463
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef_server.id}"
}

# oc_bifrost (nginx LB)
resource "aws_security_group_rule" "ingress_chef_server_allow_9683_tcp" {
  type = "ingress"
  from_port = 9683
  to_port = 9683
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
  name        = "chef_automate_${var.automate_instance_id}"
  description = "Terraform Chef Automate Server"
  vpc_id      = "${var.automate_vpc}"

  tags {
    Name = "${var.automate_tag}_chef_automate_security_group"
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
  name        = "build_nodes_${var.automate_instance_id}"
  description = "Terraform Build Nodes"
  vpc_id      = "${var.automate_vpc}"

  tags {
    Name = "${var.automate_tag}_build_nodes_security_group"
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

data "template_file" "chef_server" {
  template = "${file("./chef_server.tpl")}"
}

resource "aws_instance" "chef_server" {
  connection {
    user     = "${var.aws_ami_user}"
    key_file = ".keys/${var.aws_key_pair_name}.pem"
  }

  ami             = "${var.aws_ami_rhel}"
  instance_type   = "${var.aws_instance_type}"
  key_name        = "${var.aws_key_pair_name}"
  subnet_id       = "${var.automate_subnet}"
  vpc_security_group_ids = ["${aws_security_group.chef_server.id}"]

  ebs_optimized   = true

  root_block_device {
    delete_on_termination = true
    volume_size = 100
    volume_type = "io1"
    iops        = 5000
  }

  tags {
    Name      = "${format("${var.automate_tag}_chef_server_%02d_${var.automate_instance_id}", count.index + 1)}"
    X-Project = "CSE"
  }

  # Set hostname in separate connection.
  # Transient hostname doesn't set correctly in time otherwise.
  provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname ${aws_instance.chef_server.public_dns}"]
  }

  provisioner "file" {
    content      = "${data.template_file.chef_server.rendered}"
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

resource "aws_instance" "build_nodes" {
  connection {
    user     = "${var.aws_ami_user}"
    key_file = ".keys/${var.aws_key_pair_name}.pem"
  }

  ami             = "${var.aws_ami_rhel}"
  instance_type   = "${var.aws_build_node_instance_type}"
  key_name        = "${var.aws_key_pair_name}"
  subnet_id       = "${var.automate_subnet}"
  vpc_security_group_ids = ["${aws_security_group.build_nodes.id}"]
  ebs_optimized   = false
  count = 3

  root_block_device {
    delete_on_termination = true
    volume_size = 20
    volume_type = "io1"
    iops        = 1000
  }

  tags {
    Name      = "${format("${var.automate_tag}_build_node_%02d_${var.automate_instance_id}", count.index + 1)}"
    X-Project = "CSE"
  }

  # We've got to do this for now because delivery-ctl install-build-node will not allow you to execute without a value in password.
  # My workaround is to create a user with a password and sudo, use that one to auth, then we'll delete it later?
  # The real solution is a PR to automate.
  # TODO: PR to automate, Cleanup remote exec after
  # (Or, I'm missing something obvious.)
  provisioner "remote-exec" {
    inline = [
      "sudo useradd chef -p \\$6\\$sBhkyEwj\\$NZAqoAs3zFOygX2nH.wouLwe6h3zMgXnp3IVgLCTzrsJn1hVUU8qmH3kzyQCAVwtRGOQpfrZKvwtUx\\/1qWZjq0",
      "sudo bash -c 'echo \"chef ALL=(ALL) NOPASSWD:ALL\" > /etc/sudoers.d/80-chef-users'",
      "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config",
      "sudo service sshd restart",
    ]
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
  subnet_id       = "${var.automate_subnet}"
  vpc_security_group_ids = ["${aws_security_group.chef_automate.id}"]
  ebs_optimized   = true

  root_block_device {
    delete_on_termination = true
    volume_size = 100
    volume_type = "io1"
    iops        = 5000
  }

  tags {
    Name      = "${format("${var.automate_tag}_chef_automate_%02d_${var.automate_instance_id}", count.index + 1)}"
    X-Project = "CSE"
  }

  # Set hostname in separate connection.
  # Transient hostname doesn't set correctly in time otherwise.
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${aws_instance.chef_automate.public_dns}",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo curl -o /home/ec2-user/delivery-0.5.204-1.el7.x86_64.rpm -L https://packages.chef.io/stable/el/7/delivery-0.5.204-1.el7.x86_64.rpm",
      "sudo rpm -Uvh -i /home/ec2-user/delivery-0.5.204-1.el7.x86_64.rpm"
    ]
  }
}

data "template_file" "chef_automate" {
  template = "${file("./chef_automate.tpl")}"
  vars {
    chef_server_public_dns = "${aws_instance.chef_server.public_dns}",
    chef_automate_public_dns = "${aws_instance.chef_automate.public_dns}"
  }
}

resource "null_resource" "automate_setup" {
  connection {
    user     = "${var.aws_ami_user}"
    key_file = ".keys/${var.aws_key_pair_name}.pem"
    host     = "${aws_instance.chef_automate.public_dns}"
  }
  provisioner "file" {
    source      = "chef_automate.license"
    destination = "~/chef_automate.license"
  }
  provisioner "file" {
    source      = ".keys/chef_automate.pem"
    destination = "~/chef_automate.pem"
  }
  provisioner "file" {
    content      = "${data.template_file.chef_automate.rendered}"
    destination = "~/delivery.rb"
  }
  provisioner "file" {
    source      = ".keys/builder_key"
    destination = "~/builder_key"
  }
  provisioner "file" {
    source      = ".keys/builder_key.pub"
    destination = "~/builder_key.pub"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo curl -o /home/ec2-user/chefdk-0.17.17-1.el7.x86_64.rpm -L https://packages.chef.io/stable/el/7/chefdk-0.17.17-1.el7.x86_64.rpm",
      "sudo mkdir /etc/delivery",
      "sudo cp /home/ec2-user/chef_automate.pem /etc/delivery/delivery.pem",
      "sudo cp /home/ec2-user/delivery.rb /etc/delivery",
      "sudo mkdir -p /var/opt/delivery/license/",
      "sudo cp /home/ec2-user/chef_automate.license /var/opt/delivery/license/delivery.license",
      "sudo chown root:root /etc/delivery/*",
      "sudo delivery-ctl reconfigure",
      "sudo mv /home/ec2-user/builder_key* /etc/delivery/",
      "sudo delivery-ctl create-enterprise delivery --ssh-pub-key-file=/etc/delivery/builder_key.pub > /home/ec2-user/admin.creds",
      "sudo delivery-ctl install-build-node --fqdn ${aws_instance.build_nodes.0.public_dns} --username chef --installer /home/ec2-user/chefdk-0.17.17-1.el7.x86_64.rpm --password chef --overwrite-registration",
      "sudo delivery-ctl install-build-node --fqdn ${aws_instance.build_nodes.1.public_dns} --username chef --installer /home/ec2-user/chefdk-0.17.17-1.el7.x86_64.rpm --password chef --overwrite-registration",
      "sudo delivery-ctl install-build-node --fqdn ${aws_instance.build_nodes.2.public_dns} --username chef --installer /home/ec2-user/chefdk-0.17.17-1.el7.x86_64.rpm --password chef --overwrite-registration",
      "sudo chown ec2-user:ec2-user /home/ec2-user/admin.creds",
    ]
  }
  provisioner "local-exec" {
    command = "scp -oStrictHostKeyChecking=no -i .keys/${var.aws_key_pair_name}.pem ${var.aws_ami_user}@${aws_instance.chef_automate.public_dns}:~/admin.creds ./"
  }
}
