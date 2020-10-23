provider "azurerm" {
  version = ">= 2.31.1"
  features {}
}

variable "tenant_id" {
  type        = string
  description = "The tenant_id is used to set the root_parent_id value for the enterprise_scale module."
}

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "0.0.6-preview"

  # Mandatory Variables
  root_parent_id            = var.tenant_id

  # Optional Variables
  root_id                   = "tf"                // Define a custom ID to use for the root Management Group. Also used as a prefix for all core Management Group IDs.
  root_name                 = "ES Terraform Demo" // Define a custom "friendly name" for the root Management Group
  deploy_core_landing_zones = false                // Control whether to deploy the default core landing zones // default = true
  deploy_demo_landing_zones = false               // Control whether to deploy the demo landing zones (default = false)
  library_path              = "${path.root}/lib"  // Set a path for the custom archetype library path
}