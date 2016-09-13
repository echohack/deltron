tf_chef_automate is a blueprint for creating your own [Chef Automate](https://www.chef.io/automate/) cluster in AWS, using Terraform.

# Quickstart

1. `git clone` the repo.
1. Remove *.tfvars and *.tfstate from your .gitignore.
1. Create a terraform.tfvars file and include your variables there. See the included example.tfvars.
1. Create a secrets.tfvars file and include any keys and secrets there. See the included example_secrets.tfvars.
1. Run `terraform plan -var-file secrets.tfvars`.
1. Run `terraform apply -var-file secrets.tfvars`.
1. Create a new private repo and commit your `terraform.tfvars`, `terraform.tfstate`, and any changes to your own repository.

# Builder keys

You must provide a public/private builder key pair. They must be in ``.keys/builder_key` and ``.keys/builder_key.pub` for now.

You can generate them using `ssh-keygen -t rsa`, or however you prefer to generate your ssh keys.
