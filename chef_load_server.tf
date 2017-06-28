resource "aws_instance" "chef_load" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "${var.aws_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${data.aws_subnet_ids.automate.ids[1]}"
  vpc_security_group_ids      = ["${aws_security_group.chef_automate.id}"]
  associate_public_ip_address = true
  ebs_optimized               = true

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
    Name      = "${format("${var.automate_tag}_chef_load_%02d_${random_id.automate_instance_id.hex}", count.index + 1)}"
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

  provisioner "file" {
    source      = "chef_load.conf.tpl"
    destination = "/home/centos/chef_load.conf"
  }

  data "template_file" "chef_load.conf" {
    template = "${file("${path.module}/chef_load.conf.tpl")}"

    vars {
      chef_server_fqdn     = "${aws_instance.chef_server.public_dns}"
      automate_server_fqdn = "${aws_instance.chef_automate.public_dns}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.delivery_validator.rendered}"
    destination = "/home/centos/delivery-validator.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash -ex /tmp/mount_data_volume",
      "sudo yum install git -y",
      "cd && git clone https://github.com/jeremiahsnapp/chef-load.git",
      "wget https://github.com/chef/chef-load/releases/download/v1.0.0/chef-load_1.0.0_Linux_64bit -O chef-load-1.0.0",
      "chmod +x chef-load-1.0.0",
      "chmod 600 delivery-validator.pem",
    ]
  }
}
