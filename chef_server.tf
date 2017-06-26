

# Chef Server
resource "aws_instance" "chef_server" {
  connection {
    user     = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami             = "${data.aws_ami.centos.id}"
  instance_type   = "${var.aws_instance_type}"
  key_name        = "${var.aws_key_pair_name}"
  subnet_id       = "${data.aws_subnet_ids.automate.ids[1]}"
  vpc_security_group_ids = ["${aws_security_group.chef_server.id}"]
  associate_public_ip_address = true
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
    Name      = "${format("${var.automate_tag}_chef_server_%02d_${random_id.automate_instance_id.hex}", count.index + 1)}"
    X-Dept    = "${var.tag_dept}"
    X-Contact = "${var.tag_contact}"
  }

  # instead of setup.sh
  provisioner "local-exec" {
    command = "test -f .chef/delivery-validator.pem || ssh-keygen -t rsa -N '' -f .chef/delivery-validator.pem ; openssl rsa -in .chef/delivery-validator.pem -pubout -out .chef/delivery-validator.pub"
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

  provisioner "file" {
    source = "files/installer.sh"
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
  template = "${file(".chef/delivery-validator.pem")}"
  # vars {
  #   delivery_validator = "${file(".chef/delivery-validator.pem")}"
  # }
  depends_on = ["aws_instance.chef_server"]
}
