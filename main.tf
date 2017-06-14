# Minimum version and future backend configuration
terraform {
  required_version = "0.9.8"
}

# Automate customization
variable "chef-delivery-enterprise" { default = "terraform" }
variable "chef-server-organization" { default = "terraform" }
resource "random_id" "automate_instance_id" { byte_length = 4 }

# VPC networking
variable "aws_region" { default = "us-west-2" }
variable "aws_profile" { default = "default" }
variable "automate_vpc" { default = "vpc-fa58989d" } # jhud-vpc in success-aws
data "aws_subnet_ids" "automate" { vpc_id = "${var.automate_vpc}" }

# unique identifier for this instance of Chef Automate
variable "aws_build_node_instance_type" { default = "t2.medium" }
variable "aws_instance_type" { default = "m4.xlarge" }
variable "aws_ami_user" { default = "centos" }
variable "aws_key_pair_name" { default = "irving" }
variable "aws_key_pair_file" { default = "~/.ssh/id_rsa" }

# Tagging
variable "automate_tag" { default = "terraform_automate" }
variable "tag_dept" { default = "SCE" }
variable "tag_contact" { default = "irving" }

# Basic AWS info
provider "aws" {
  region                  = "${var.aws_region}"
  profile                 = "${var.aws_profile}" // uses ~/.aws/credentials by default
}

data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["chef-highperf-centos7-201706012343"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["446539779517"]
}
