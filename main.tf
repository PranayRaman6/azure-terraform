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
  root_parent_id = var.tenant_id

  # Optional Variables
  root_id   = "py"                // This string variable is used for the root Management Group ID and as a prefix for all core Management Group IDs
  root_name = "PY Terraform Demo" // This string variable is used as a friendly name for the root Management Group
}