# Chef Server
resource "null_resource" "generate_chef_keypair" {
  # instead of setup.sh
  provisioner "local-exec" {
    command = "test -f .chef/delivery-validator-${random_id.automate_instance_id.hex}.pem || ssh-keygen -t rsa -N '' -f .chef/delivery-validator-${random_id.automate_instance_id.hex}.pem ; openssl rsa -in .chef/delivery-validator-${random_id.automate_instance_id.hex}.pem -pubout -out .chef/delivery-validator-${random_id.automate_instance_id.hex}.pub"
  }
}

resource "aws_instance" "chef_server" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${data.aws_ami.centos.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.cloudwatch_metrics_instance_profile.id}"
  instance_type               = "${var.chef_server_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${var.automate_subnet}"
  vpc_security_group_ids      = ["${aws_security_group.chef_server.id}"]
  associate_public_ip_address = true
  ebs_optimized               = true

  root_block_device {
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }

  tags {
    Name      = "${format("${var.automate_tag}_${random_id.automate_instance_id.hex}_chef_server_%02d", count.index + 1)}"
    X-Dept    = "${var.tag_dept}"
    X-Contact = "${var.tag_contact}"
    TestId    = "${var.tag_test_id}"
  }

  # Set hostname in separate connection.
  # Transient hostname doesn't set correctly in time otherwise.
  provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname ${aws_instance.chef_server.public_dns}"]
  }

  provisioner "file" {
    source      = ".chef/delivery-validator-${random_id.automate_instance_id.hex}.pub"
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
  depends_on = ["null_resource.generate_chef_keypair"]
}

# template to delay reading of validator key
data "template_file" "delivery_validator" {
  template = "${file(".chef/delivery-validator-${random_id.automate_instance_id.hex}.pem")}"

  vars {
    hacky_thing_to_delay_evaluation = "${aws_instance.chef_server.private_ip}"
  }
  depends_on = ["aws_instance.chef_server"]
}

# TODO: write out a knife.rb
# data "template_file" "knife_rb" {
#   template = <<-EOF
#   current_dir = File.dirname(__FILE__)
#   log_level                :info
#   log_location             STDOUT
#   node_name                "delivery-validator"
#   client_key               ".chef/delivery-validator-${random_id.automate_instance_id.hex}.pem"
#   chef_server_url          "https://api.opscode.com/organizations/irvingpop"
#   cache_type               'BasicFile'
#   cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
#   EOF
#
#   vars {
#     consul_address = "${aws_instance.consul.private_ip}"
#   }
# }

output "chef_server" {
  value = "${aws_instance.chef_server.public_dns}"
}
