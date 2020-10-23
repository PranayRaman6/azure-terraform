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
  root_id      = "yup"              // This string variable is used for the root Management Group ID and as a prefix for all core Management Group IDs
  root_name    = "YUP Campus Cloud" // This string variable is used as a friendly name for the root Management Group
  library_path = "${path.root}/lib" // This string variable is used to define the location of your custom library

  custom_landing_zones = {
    campus-cloud = {
      display_name               = "YUP Platform"
      parent_management_group_id = "yup"
      subscription_ids           = []

      archetype_config = {
        archetype_id   = "yup_platform"
        parameters     = {}
        access_control = {}
      }
    }
  }
}