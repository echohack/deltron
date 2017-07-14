terraform {
  required_version = ">= 0.9.9"
}

# Automate customization
variable "chef-delivery-enterprise" {
  default = "terraform"
}

variable "chef-server-organization" {
  default = "terraform"
}

resource "random_id" "automate_instance_id" {
  byte_length = 4
}

# VPC networking
variable "aws_region" {
  default = "us-west-2"
}

variable "aws_profile" {
  default = "default"
}

variable "automate_vpc" {
  default = "vpc-fa58989d"
} # jhud-vpc in success-aws

variable "automate_subnet" {
  default = "subnet-63c62b04"
}

data "aws_subnet_ids" "automate" {
  vpc_id = "${var.automate_vpc}"
}

# unique identifier for this instance of Chef Automate
variable "aws_build_node_instance_type" {
  default = "t2.medium"
}

variable "chef_server_instance_type" {
  default = "m4.xlarge"
}

variable "automate_server_instance_type" {
  default = "m4.xlarge"
}

variable "es_backend_instance_type" {
  default = "m4.xlarge"
}

variable "chef_load_instance_type" {
  default = "m4.xlarge"
}

variable "aws_ami_user" {
  default = "centos"
}

variable "aws_key_pair_name" { }

variable "aws_key_pair_file" { }

variable "automate_es_recipe" {
  default = "recipe[backend_search_cluster::search_es]"
}

# Tagging
variable "automate_tag" {
  default = "terraform_automate"
}

variable "tag_dept" {
  default = "SCE"
}

variable "tag_contact" {
  default = "irving"
}

variable "tag_test_id" {
  default = "automate_scale_test"
}

variable "chef_load_rpm" {
  default = "334"   # 10k nodes splayed at 30 min interval
}

variable "external_es_count" {
  default = 3
}

variable "converge_status_json_path" {
  default = "/home/centos/jnj_json/jnj_mostly_original_converge_event.json"
}

variable "ohai_json_path" {
  default = "/home/centos/jnj_json/jnj_ohai.json"
}

variable "compliance_status_json_path" {
  default = "/home/centos/chef-load/sample-data/example-compliance-status.json"
}

variable "s3_json_bucket" {
  default = "jhud-backendless-chef2-chefbucket-10qcdk8zn9z9i"
}

variable "logstash_total_procs" {
  default = 1
}

variable "logstash_heap_size" {
  default = "1g"
}

variable "logstash_bulk_size" {
  default = "256"
}

variable "es_index_shard_count" {
  default = 5
}

variable "es_max_content_length" {
  default = "1gb"
}

variable "es_backend_volume_size" {
  default = 100
}

variable "logstash_workers" {
  default = 12
}

variable "chef_load_count" {
  default = 1
}

# Basic AWS info
provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}" // uses ~/.aws/credentials by default
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

resource "aws_iam_role" "cloudwatch_metrics_role" {
  name = "cloudwatch_metrics_role_${random_id.automate_instance_id.hex}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_metrics_policy" {
  name = "cloudwatch_metrics_policy_${random_id.automate_instance_id.hex}"
  role = "${aws_iam_role.cloudwatch_metrics_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1499208295508",
      "Action": [
        "ec2:DescribeTags",
        "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "Stmt1499208317792",
      "Action": [
        "cloudwatch:ListMetrics",
        "cloudwatch:PutMetricData",
        "ec2:DescribeInstances",
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "cloudwatch_metrics_instance_profile" {
  name = "cloudwatch_metrics_instance_profile_${random_id.automate_instance_id.hex}"
  role = "${aws_iam_role.cloudwatch_metrics_role.name}"
}
