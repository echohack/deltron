_Deltron_ is a blueprint for creating your own [Chef Automate](https://www.chef.io/automate/) cluster in AWS, using Terraform.

Note: there are still bugs as this is under heavy development

# Quickstart

1. review the variables in main.tf and decide which ones you're going to override
2. set up your environment variables with the overrides like:
```
export TF_VAR_aws_region="us-west-2"
export TF_VAR_aws_profile="default"
export TF_VAR_automate_vpc="vpc-fa58989d"
export TF_VAR_aws_key_pair_name="mykeypair"
export TF_VAR_aws_key_pair_file="~/.ssh/id_rsa"
export TF_VAR_tag_dept="MyDepartment"
export TF_VAR_tag_contact="My Name"
```
3. run `terraform plan` to see what it will do
4. run `terraform apply` to build the infrastructure
5. run `terraform destroy` to tear everything down
