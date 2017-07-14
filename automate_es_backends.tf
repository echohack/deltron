resource "aws_instance" "es_backend" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                    = "${data.aws_ami.centos.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.cloudwatch_metrics_instance_profile.id}"
  instance_type          = "${var.es_backend_instance_type}"
  key_name               = "${var.aws_key_pair_name}"
  subnet_id              = "${var.automate_subnet}"
  vpc_security_group_ids = ["${aws_security_group.chef_automate.id}"]
  ebs_optimized          = false
  count                  = "${var.external_es_count}"
  depends_on             = ["aws_instance.es_backend"]                # run in serial

  root_block_device {
    delete_on_termination = true
    volume_size           = "${var.es_backend_volume_size}"
    volume_type           = "gp2"
  }

  tags {
    Name      = "${format("${var.automate_tag}_${random_id.automate_instance_id.hex}_esbackend_%02d", count.index + 1)}"
    X-Dept    = "${var.tag_dept}"
    X-Contact = "${var.tag_contact}"
    TestId    = "${var.tag_test_id}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.public_dns}",
    ]
  }

  provisioner "chef" {
    attributes_json = <<-EOF
      {
        "tags": "es_backend",
        "aws": {
          "region": "${var.aws_region}"
        },
        "search_bootstrap": "${aws_instance.es_backend.0.public_dns}",
        "elasticsearch": {
          "cluster_name": "elasticsearch_${random_id.automate_instance_id.hex}",
          "es_number_of_shards": "${var.es_index_shard_count}",
          "es_max_content_length": "${var.es_max_content_length}"
        },
        "chef_server": {
            "fqdn": "${aws_instance.chef_server.public_dns}"
        }
      }
      EOF

    environment             = "_default"
    node_name               = "es-backend${self.id}-${count.index + 1}"
    fetch_chef_certificates = true
    run_list                = ["${var.automate_es_recipe}", "collect_metrics::es_backend"]
    server_url              = "https://${aws_instance.chef_server.public_dns}/organizations/delivery"
    user_name               = "delivery-validator"
    user_key                = "${data.template_file.delivery_validator.rendered}"
    client_options          = ["trusted_certs_dir '/etc/chef/trusted_certs'"]
  }

  provisioner "remote-exec" {
    inline = [
      "cd && wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64",
      "chmod +x jq-linux64",
    ]
  }
}

output "es_backends" {
  value = "${join(", ", aws_instance.es_backend.*.public_dns)}"
}
