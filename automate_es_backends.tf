

 resource "aws_instance" "es_backend" {
   connection {
     user     = "${var.aws_ami_user}"
     private_key = "${file(".keys/${var.aws_key_pair_name}.pem")}"
   }

   ami             = "${data.aws_ami.centos.id}"
   instance_type   = "${var.aws_instance_type}"
   key_name        = "${var.aws_key_pair_name}"
   subnet_id       = "${var.automate_subnet}"
   vpc_security_group_ids = ["${aws_security_group.chef_automate.id}"]
   ebs_optimized   = false
   count = 3

   root_block_device {
     delete_on_termination = true
     volume_size = 100
     volume_type = "gp2"
   }

   tags {
     Name      = "${format("${var.automate_tag}_esbackend_%02d_${var.automate_instance_id}", count.index + 1)}"
     X-Dept    = "${var.tag_dept}"
     X-Contact = "${var.tag_contact}"
   }

    provisioner "remote-exec" {
      inline = [
        "sudo hostnamectl set-hostname ${self.public_dns}",
      ]
    }

    provisioner "chef"  {
      attributes_json = <<-EOF
      {
        "tags": "es_backend",
        "search_bootstrap": "${aws_instance.es_backend.0.public_dns}",
        "chef_server": {
            "fqdn": "${aws_instance.chef_server.public_dns}"
        }
      }
      EOF
      environment = "_default"
      node_name = "es-backend${self.id}-${count.index + 1}"
      fetch_chef_certificates = true
      run_list = ["backend_search_cluster::search_backend"]
      server_url = "https://${aws_instance.chef_server.public_dns}/organizations/delivery"
      user_name = "delivery-validator"
      user_key = "${data.template_file.delivery_validator.rendered}"
      client_options = ["trusted_certs_dir '/etc/chef/trusted_certs'"]
    }
 }
