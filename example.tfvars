# fake example data

# rename this file to terraform.tfvars so terraform automatically gets variables
# during the run. See: https://www.terraform.io/intro/getting-started/variables.html
aws_default_region = "us-west-2"
aws_instance_type = "m4.xlarge"
automate_instance_id = "myface_d3e1d124" # unique identifier for this instance of Chef Automate

tag_dept = "mydepartment"
tag_contact = "user@example.com"

automate_vpc = "vpc-34e92e01"
automate_subnet = "subnet-3cd236e4"
