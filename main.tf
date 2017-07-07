terraform {
  required_version = "0.9.9"
}

provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}" // uses ~/.aws/credentials by default
}

resource "random_id" "automate_instance_id" {
  byte_length = 4
}

data "aws_subnet_ids" "automate" {
  vpc_id = "${var.automate_vpc}"
}

data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["chef-highperf-centos7-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["446539779517"]
}

# Chef Server
resource "aws_instance" "chef_server" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "${var.aws_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${data.aws_subnet_ids.automate.ids[1]}"
  vpc_security_group_ids      = ["${aws_security_group.chef_server.id}"]
  associate_public_ip_address = true
  ebs_optimized               = true

  root_block_device {
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp2"

    #iops = 1000
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_type           = "io1"
    iops                  = 5000       # iops = volume_size * 50
    volume_size           = 100
    delete_on_termination = true
  }

  tags {
    Name      = "${format("${var.tag_automate}_${random_id.automate_instance_id.hex}_chef_server_%02d", count.index + 1)}"
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
    source      = "mount_data_volume"
    destination = "/tmp/mount_data_volume"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash -ex /tmp/mount_data_volume",
    ]
  }

  provisioner "file" {
    source      = ".chef/delivery-validator.pub"
    destination = "/tmp/pre-delivery-validator.pub"
  }

  provisioner "file" {
    source      = "files/installer.sh"
    destination = "/tmp/installer.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo SVWAIT=30 bash /tmp/installer.sh -c ${aws_instance.chef_server.public_dns}",
      "sudo chef-server-ctl add-client-key delivery delivery-validator --public-key-path /tmp/pre-delivery-validator.pub",
    ]
  }
}

# template to delay reading of validator key
data "template_file" "delivery_validator" {
  vars {
    delivery_validator = "${file(".chef/delivery-validator.pem")}"
  }

  template   = "$${delivery_validator}"
  depends_on = ["aws_instance.chef_server"]
}

resource "aws_instance" "chef_automate" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                    = "${data.aws_ami.centos.id}"
  instance_type          = "${var.aws_instance_type}"
  key_name               = "${var.aws_key_pair_name}"
  subnet_id              = "${data.aws_subnet_ids.automate.ids[1]}"
  vpc_security_group_ids = ["${aws_security_group.chef_automate.id}"]
  ebs_optimized          = true

  root_block_device {
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp2"

    #iops        = 1000
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_type           = "io1"
    iops                  = 5000       # iops = volume_size * 50
    volume_size           = 100
    delete_on_termination = true
  }

  tags {
    Name      = "${format("${var.tag_automate}_${random_id.automate_instance_id.hex}_chef_automate_%02d", count.index + 1)}"
    X-Dept    = "${var.tag_dept}"
    X-Contact = "${var.tag_contact}"
  }

  # Set hostname in separate connection.
  # Transient hostname doesn't set correctly in time otherwise.
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${aws_instance.chef_automate.public_dns}",
      "sudo mkdir /etc/chef/",
    ]
  }

  # mount the EBS volume
  provisioner "file" {
    source      = "mount_data_volume"
    destination = "/tmp/mount_data_volume"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash -ex /tmp/mount_data_volume",
    ]
  }

  provisioner "file" {
    source      = "chef_automate.license"
    destination = "~/chef_automate.license"
  }

  provisioner "chef" {
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

    environment             = "_default"
    fetch_chef_certificates = true
    run_list                = ["chef-services::delivery"]
    node_name               = "${aws_instance.chef_automate.public_dns}"
    server_url              = "https://${aws_instance.chef_server.public_dns}/organizations/delivery"
    user_name               = "delivery-validator"
    user_key                = "${data.template_file.delivery_validator.rendered}"
    client_options          = ["trusted_certs_dir = '/etc/chef/trusted_certs'"]
  }

  provisioner "local-exec" {
    command = "scp -oStrictHostKeyChecking=no -i ${var.aws_key_pair_file} ${var.aws_ami_user}@${aws_instance.chef_automate.public_dns}:/tmp/test.creds ./"
  }
}

resource "aws_instance" "build_nodes" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                    = "${data.aws_ami.centos.id}"
  instance_type          = "t2.medium"
  key_name               = "${var.aws_key_pair_name}"
  subnet_id              = "${data.aws_subnet_ids.automate.ids[1]}"
  vpc_security_group_ids = ["${aws_security_group.build_nodes.id}"]
  ebs_optimized          = false
  count                  = 3

  root_block_device {
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }

  tags {
    Name      = "${format("${var.tag_automate}_build_node_%02d_${random_id.automate_instance_id.hex}", count.index + 1)}"
    X-Dept    = "${var.tag_dept}"
    X-Contact = "${var.tag_contact}"
  }

  provisioner "chef" {
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

    environment             = "_default"
    node_name               = "build-node-${count.index + 1}"
    fetch_chef_certificates = true
    run_list                = ["chef-services::install_build_nodes"]
    server_url              = "https://${aws_instance.chef_server.public_dns}/organizations/delivery"
    user_name               = "delivery-validator"
    user_key                = "${data.template_file.delivery_validator.rendered}"
    client_options          = ["trusted_certs_dir '/etc/chef/trusted_certs'"]
  }
}
