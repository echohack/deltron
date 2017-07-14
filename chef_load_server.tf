data "template_file" "chef_load_conf" {
  template = "${file("./chef_load.conf.tpl")}"

  vars {
    chef_server_fqdn     = "${aws_instance.chef_server.public_dns}"
    automate_server_fqdn = "${aws_instance.chef_automate.public_dns}"
    rpm = "${var.chef_load_rpm}"
    ohai_json_path = "${var.ohai_json_path}"
    compliance_status_json_path = "${var.compliance_status_json_path}"
    converge_status_json_path = "${var.converge_status_json_path}"
  }
}

resource "aws_instance" "chef_load" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${data.aws_ami.centos.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.cloudwatch_metrics_instance_profile.id}"
  instance_type               = "${var.chef_load_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${var.automate_subnet}"
  vpc_security_group_ids      = ["${aws_security_group.chef_automate.id}"]
  associate_public_ip_address = true
  ebs_optimized               = true
  count                  = "${var.chef_load_count}"

  root_block_device {
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp2"

    #iops        = 1000
  }

  tags {
    Name      = "${format("${var.automate_tag}_${random_id.automate_instance_id.hex}_chef_load_%02d", count.index + 1)}"
    X-Dept    = "${var.tag_dept}"
    X-Contact = "${var.tag_contact}"
    TestId    = "${var.tag_test_id}"
  }

  # Set hostname in separate connection.
  # Transient hostname doesn't set correctly in time otherwise.
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${aws_instance.chef_automate.public_dns}",
      "sudo mkdir /etc/chef/",
    ]
  }

  provisioner "file" {
    content     = "${data.template_file.delivery_validator.rendered}"
    destination = "/home/centos/delivery-validator.pem"
  }

  provisioner "file" {
    content = "${data.template_file.chef_load_conf.rendered}"
    destination = "/home/centos/chef_load.conf"
  }

  provisioner "file" {
    source = "./files/chef_load.service"
    destination = "/tmp/chef_load.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/chef_load.service /etc/systemd/system/chef_load.service",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install git nscd -y",
      "cd && git clone https://github.com/jeremiahsnapp/chef-load.git",
      "wget https://github.com/chef/chef-load/releases/download/v1.0.0/chef-load_1.0.0_Linux_64bit -O chef-load-1.0.0",
      "chmod +x chef-load-1.0.0",
      "chmod 600 delivery-validator.pem",
      "knife ssl fetch https://${aws_instance.chef_server.public_dns}",
      "aws s3 cp s3://${var.s3_json_bucket}/jnj_json.tar /home/centos/jnj_json.tar",
      "tar -xzf /home/centos/jnj_json.tar",
      "sudo systemctl start chef_load",
    ]
  }
}

output "chef_load_server" {
  value = "${aws_instance.chef_load.public_dns}"
}
