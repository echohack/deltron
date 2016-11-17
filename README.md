_Deltron_ is a blueprint for creating your own [Chef Automate](https://www.chef.io/automate/) cluster in AWS, using Terraform.

# Quickstart

1. `git clone` the repo.
1. Remove *.tfvars and *.tfstate from your .gitignore.
1. Execute `setup.sh` from the root of the directory
1. Create a terraform.tfvars file and include your variables there. See the included example.tfvars.
1. Create a secrets.tfvars file and include any keys and secrets there. See the included example_secrets.tfvars.
1. Run `terraform plan -var-file secrets.tfvars`.
1. Run `terraform apply -var-file secrets.tfvars`.
1. Create a new private repo and commit your `terraform.tfvars`, `terraform.tfstate`, and any changes to your own repository.

# Variables in terraform.tfvars

- aws_default_region - The region name where your aws instances will live. Choose from one of the following:

    us-west-1

    us-west-2

    us-east-1

    eu-west-1

    eu-central-1

    ap-southeast-1

    ap-southeast-2

    ap-northeast-1

    ap-northeast-2

- aws_instance_type - The size and type of machines you will spin up for all Chef Automate instances.
- automate_instance_id - A unique identifier added to the names and tags of the machines to make finding them easier.

## VPCs, Security Groups, and Route Tables
This project assumes that your security team has already created VPCs, security_groups, and route tables where applications can live in your organization. You should question your security team to understand their operating model, architecture, and maintenance of VPCs, Security Groups, and Route Tables. If this is not the case and your organization permits dynamic allocation of these resources, then you should modify the `main.tf` file to use terraform resources to maintain these.

- automate_vpc - The [VPC](https://aws.amazon.com/vpc/) under which all aws resources you spin up will be created.
- automate_subnet - The [Subnet](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html) under which all aws resource will be created.
- automate_route_table_id - The [Route Table](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Route_Tables.html) under which all aws resources will be created.

# Builder keys

You no longer need to provide builder keys.

# Setup.sh

Because of how Terraform's file interpolation works, files are read pre-execution. To work around this, we
generate a validator key for the Delivery user in this script. If we can find a way to do this in the TF plan
in the future, we should do so.
