provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region     = "${var.aws_default_region}"
}

resource "aws_security_group" "chef_server" {
  name        = "chef_server_${var.automate_instance_id}"
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
  name        = "chef_automate_${var.automate_instance_id}"
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
  name        = "build_nodes_${var.automate_instance_id}"
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

# Chef Server
resource "aws_instance" "chef_server" {
  connection {
    user     = "${var.aws_ami_user}"
    private_key = "${file(".keys/${var.aws_key_pair_name}.pem")}"
  }

  ami             = "${var.aws_ami_rhel}"
  instance_type   = "${var.aws_instance_type}"
  key_name        = "${var.aws_key_pair_name}"
  subnet_id       = "${var.automate_subnet}"
  vpc_security_group_ids = ["${aws_security_group.chef_server.id}"]
  ebs_optimized   = true

  root_block_device {
    delete_on_termination = true
    volume_size = 20
    volume_type = "gp2"
    #iops = 1000
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "io1"
    iops = 5000 # iops = volume_size * 50
    volume_size = 100
    delete_on_termination = true
  }

  tags {
    Name      = "${format("${var.automate_tag}_chef_server_%02d_${var.automate_instance_id}", count.index + 1)}"
    X-Dept    = "${var.tag_dept}"
    X-Contact = "${var.tag_contact}"
  }

  # Set hostname in separate connection.
  # Transient hostname doesn't set correctly in time otherwise.
  provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname ${aws_instance.chef_server.public_dns}"]
  }

  # mount the EBS volume
  provisioner "file" {
    source = "mount_data_volume"
    destination = "/tmp/mount_data_volume"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo bash -ex /tmp/mount_data_volume"
    ]
  }
  provisioner "file" {
    source = ".chef/delivery-validator.pub"
    destination = "/tmp/pre-delivery-validator.pub"
  }
  provisioner "remote-exec" {
    inline = [
      "curl -L http://chef-installer.chameleon-development.ca -o installer.sh && sudo SVWAIT=30 bash ./installer.sh -c ${aws_instance.chef_server.public_dns}",
      "sudo chef-server-ctl add-client-key delivery delivery-validator --public-key-path /tmp/pre-delivery-validator.pub"
    ]
  }
}

# template to delay reading of validator key
data "template_file" "delivery_validator" {
  template = "${delivery_validator}"
  vars {
    delivery_validator = "${file(".chef/delivery-validator.pem")}"
  }
  depends_on = ["aws_instance.chef_server"]
}

resource "aws_instance" "chef_automate" {
  connection {
    user     = "${var.aws_ami_user}"
    private_key = "${file(".keys/${var.aws_key_pair_name}.pem")}"
  }

  ami             = "${var.aws_ami_rhel}"
  instance_type   = "${var.aws_instance_type}"
  key_name        = "${var.aws_key_pair_name}"
  subnet_id       = "${var.automate_subnet}"
  vpc_security_group_ids = ["${aws_security_group.chef_automate.id}"]
  ebs_optimized   = true

  root_block_device {
    delete_on_termination = true
    volume_size = 20
    volume_type = "gp2"
    #iops        = 1000
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "io1"
    iops = 5000 # iops = volume_size * 50
    volume_size = 100
    delete_on_termination = true
  }

  tags {
    Name      = "${format("${var.automate_tag}_chef_automate_%02d_${var.automate_instance_id}", count.index + 1)}"
    X-Dept    = "${var.tag_dept}"
    X-Contact = "${var.tag_contact}"
  }

  # Set hostname in separate connection.
  # Transient hostname doesn't set correctly in time otherwise.
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${aws_instance.chef_automate.public_dns}",
      "sudo mkdir /etc/chef/"
    ]
  }

  # mount the EBS volume
  provisioner "file" {
    source = "mount_data_volume"
    destination = "/tmp/mount_data_volume"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo bash -ex /tmp/mount_data_volume"
    ]
  }

  provisioner "file" {
    source      = "chef_automate.license"
    destination = "~/chef_automate.license"
  }

  provisioner "chef"  {
    attributes_json = <<-EOF
    {
        "tags": "automate_server",
        "chef_automate": {
            "fqdn": "${aws_instance.chef_automate.public_dns}"
        },
        "chef_server": {
            "fqdn": "${aws_instance.chef_server.public_dns}"
        }
    }
    EOF
    environment = "_default"
    fetch_chef_certificates = true
    run_list = ["chef-services::delivery"]
    node_name = "${aws_instance.chef_automate.public_dns}"
    server_url = "https://${aws_instance.chef_server.public_dns}/organizations/delivery"
    user_name = "delivery-validator"
    user_key = "${data.template_file.delivery_validator.rendered}"
    client_options = ["trusted_certs_dir = '/etc/chef/trusted_certs'"]
  }
  provisioner "local-exec" {
    command = "scp -oStrictHostKeyChecking=no -i .keys/${var.aws_key_pair_name}.pem ${var.aws_ami_user}@${aws_instance.chef_automate.public_dns}:/tmp/test.creds ./"
  }
}


resource "aws_instance" "build_nodes" {
  connection {
    user     = "${var.aws_ami_user}"
    private_key = "${file(".keys/${var.aws_key_pair_name}.pem")}"
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
    volume_size = 100
    volume_type = "gp2"
  }

  tags {
    Name      = "${format("${var.automate_tag}_build_node_%02d_${var.automate_instance_id}", count.index + 1)}"
    X-Dept    = "${var.tag_dept}"
    X-Contact = "${var.tag_contact}"
  }

    provisioner "chef"  {
      attributes_json = <<-EOF
      {
          "tags": "delivery-build-node",
          "chef_automate": {
              "fqdn": "${aws_instance.chef_automate.public_dns}"
          },
          "chef_server": {
              "fqdn": "${aws_instance.chef_server.public_dns}"
          }
      }
      EOF
      environment = "_default"
      node_name = "build-node-${count.index + 1}"
      fetch_chef_certificates = true
      run_list = ["chef-services::install_build_nodes"]
      server_url = "https://${aws_instance.chef_server.public_dns}/organizations/delivery"
      user_name = "delivery-validator"
      user_key = "${data.template_file.delivery_validator.rendered}"
      client_options = ["trusted_certs_dir '/etc/chef/trusted_certs'"]
    }
}
