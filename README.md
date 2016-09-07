tf_chef_automate is a blueprint for creating your own [Chef Automate](https://www.chef.io/automate/) cluster in AWS, using Terraform.

# Quickstart

1. `git clone` the repo.
1. Remove *.tfvars and *.tfstate from your .gitignore.
1. Create a terraform.tfvars file and include your variables there. See the included example.tfvars.
1. Create a secrets.tfvars file and include any keys and secrets there. See the included example_secrets.tfvars.
1. Run `terraform plan -var-file secrets.tfvars`.
1. Run `terraform apply -var-file secrets.tfvars`.
1. Create a new private repo and commit your `terraform.tfvars`, `terraform.tfstate`, and any changes to your own repository.
