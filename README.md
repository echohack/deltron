tf_chef_automate is a blueprint for creating your own [Chef Automate](https://www.chef.io/automate/) cluster in AWS, using Terraform.

# Quickstart

1. `git clone` the repo.
1. Remove *.tfvars and *.tfstate from your .gitignore.
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


# Delivery validator keys

You must provide your own Delivery validator key.

# Builder keys

You no longer need to provide builder keys. Once you've generated a `delivery-validator.pem` using `ssh-keygen` or your other favorite key generator, you can generate the public key in the format needed by the Chef server by using a command like `openssl rsa -in delivery-validator.pem -pubout -out delivery-validator.pub`.

The two files need to be in the `.chef` directory as `delivery-validator.pem` and `delivery-validator.pub`.

TODO: Automate that ^^

# Vendor cookbooks

Before you apply the terraform plan you need to vendor the cookbooks, you can accomplish this by running the following commands from the root of the project:

`berks install`
`berks vendor vendored-cookbooks/`
