resource "aws_instance" "chef_automate" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${data.aws_ami.centos.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.cloudwatch_metrics_instance_profile.id}"
  instance_type               = "${var.automate_server_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${var.automate_subnet}"
  vpc_security_group_ids      = ["${aws_security_group.chef_automate.id}"]
  associate_public_ip_address = true
  ebs_optimized               = true

  root_block_device {
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }

  tags {
    Name      = "${format("${var.automate_tag}_${random_id.automate_instance_id.hex}_chef_automate_%02d", count.index + 1)}"
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
    source      = "chef_automate.license"
    destination = "~/chef_automate.license"
  }

  provisioner "chef" {
    attributes_json = <<-EOF
    {
        "tags": "automate_server",
        "peers": ${jsonencode(formatlist("http://%s:9200", aws_instance.es_backend.*.public_dns))},
        "chef_automate": {
          "fqdn": "${aws_instance.chef_automate.public_dns}"
        },
        "chef_server": {
          "fqdn": "${aws_instance.chef_server.public_dns}"
        },
        "logstash": {
          "heap_size": "${var.logstash_heap_size}",
          "bulk_size": "${var.logstash_bulk_size}",
          "total_procs": "${var.logstash_total_procs}",
          "workers": "${var.logstash_workers}"
        },
        "elasticsearch": {
          "es_number_of_shards": "${var.es_index_shard_count}",
          "max_content_length": "${var.es_max_content_length}"
        }
    }
    EOF

    environment             = "_default"
    fetch_chef_certificates = true
    run_list                = ["chef-services::delivery", "collect_metrics::automate", "backend_search_cluster::logstash"]
    node_name               = "${aws_instance.chef_automate.public_dns}"
    server_url              = "https://${aws_instance.chef_server.public_dns}/organizations/delivery"
    user_name               = "delivery-validator"
    user_key                = "${data.template_file.delivery_validator.rendered}"
    client_options          = ["trusted_certs_dir = '/etc/chef/trusted_certs'"]
  }
}

output "chef_automate_server" {
  value = "${aws_instance.chef_automate.public_dns}"
}
