provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region     = "${var.aws_default_region}"
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = "${var.automate_vpc}"
  route_table_id = "${var.automate_route_table_id}"
}

resource "aws_subnet" "automate_subnet" {
  vpc_id                  = "${var.automate_vpc}"
  cidr_block              = "33.33.34.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.automate_tag}_subnet"
  }
}

resource "aws_route_table_association" "automate_public_routing" {
  subnet_id      = "${aws_subnet.automate_subnet.id}"
  route_table_id = "${var.automate_route_table_id}"
}

resource "aws_security_group" "chef_server" {
  name        = "chef_server"
  description = "Terraform Automate Chef Server"
  vpc_id      = "${var.automate_vpc}"

  tags {
    Name = "${var.automate_tag}_chef_server_security_group"
  }

  # SSH - all
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP (nginx)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS (nbinx)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # oc_bifrost
  ingress {
    from_port   = 9463
    to_port     = 9463
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # oc_bifrost (nginx LB)
  ingress {
    from_port   = 9683
    to_port     = 9683
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # opscode-push-jobs-server
  ingress {
    from_port   = 10000
    to_port     = 10003
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # egress: ALL
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "chef_server" {
  connection {
    user     = "${var.aws_ami_user}"
    key_file = ".keys/${var.aws_key_pair_name}.pem"
  }

  ami             = "${var.aws_ami_rhel}"
  instance_type   = "${var.aws_instance_type}"
  key_name        = "${var.aws_key_pair_name}"
  subnet_id       = "${aws_subnet.automate_subnet.id}"
  security_groups = ["${aws_security_group.chef_server.id}"]

  tags {
    Name      = "${format("${var.automate_tag}_chef_server_%02d", count.index + 1)}"
    X-Project = "CSE"
  }

  provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname ${aws_instance.chef_server.public_dns}"]
  }

  provisioner "file" {
    source      = "chef_server.sh"
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
