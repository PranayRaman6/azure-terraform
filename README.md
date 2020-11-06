# Azure + Terraform

![Terraform](https://github.com/pauldotyu/azure-terraform/workflows/Terraform/badge.svg)

## Get started with Terraform Cloud

1. Setup your workspace on [Terraform Cloud](https://app.terraform.io)

    > You have the option to use Version Control as the trigger or CLI-based. If you implement VCS, there is no need to configure GitHub Actions (as documented below) since Terraform Cloud will "listen" to your repo.

1. Create a service principal in Azure and add the following keys to the workspace's environment variables

    - ARM_CLIENT_ID
    - ARM_CLIENT_SECRET SENSITIVE
    - ARM_TENANT_ID
    - ARM_SUBSCRIPTION_ID

1. In Azure Portal, locate the Id of your tenant root group and add it as a variable named `tenant_id` in Terraform Cloud workspace

1. Download and install the [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli)

1. Log into Terraform Cloud using the command:

    `terraform login`

    > You will be prompted to create a new API token. You can either use this for GitHub Actions configurations (see below) or create another one later

1. Initialize against Terraform Cloud using the command:
    `terraform init`

## Get started with GitHub Actions

1. Using your Terraform API token, save a new secret named `TF_API_TOKEN` in your repository

1. Go to the Actions tab and add a new Terraform workflow

1. Keep the default workflow script or use [this](/.github/workflows/terraform.yml)

1. Head back to your workspace on Terraform Cloud and connect the workspace to your GitHub repo

## Use this doc and get your Terraform on!

- https://www.terraform.io/docs/providers/azurerm/
- https://registry.terraform.io/modules/Azure/caf-enterprise-scale/azurerm/latest
- https://github.com/Azure/terraform-azurerm-caf-enterprise-scale
