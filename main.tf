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
  root_id                   = "py"                // This string variable is used for the root Management Group ID and as a prefix for all core Management Group IDs
  root_name                 = "Paul Campus Cloud" // This string variable is used as a friendly name for the root Management Group
  deploy_core_landing_zones = false               // Control whether to deploy the default core landing zones // default = true
  deploy_demo_landing_zones = false               // Control whether to deploy the demo landing zones (default = false)
  library_path              = "${path.root}/lib"  // This string variable is used to define the location of your custom library

  custom_landing_zones = {
    py-platform = {
      display_name               = "Paul Platform"
      parent_management_group_id = "py"
      subscription_ids           = []

      archetype_config = {
        archetype_id   = "py_platform"
        parameters     = {}
        access_control = {}
      }
    }

    py-landing-zone = {
      display_name               = "Paul Landing Zone"
      parent_management_group_id = "py"
      subscription_ids           = []

      archetype_config = {
        archetype_id   = "py_landing_zone"
        parameters     = {}
        access_control = {}
      }
    }

    py-sandbox = {
      display_name               = "Paul Sandbox"
      parent_management_group_id = "py"
      subscription_ids           = []

      archetype_config = {
        archetype_id   = "py_sandbox"
        parameters     = {}
        access_control = {}
      }
    }

    py-legacy = {
      display_name               = "Paul Legacy"
      parent_management_group_id = "py"
      subscription_ids           = []

      archetype_config = {
        archetype_id   = "py_legacy"
        parameters     = {}
        access_control = {}
      }
    }

    py-qurantine = {
      display_name               = "Paul Quarantine"
      parent_management_group_id = "py"
      subscription_ids           = []

      archetype_config = {
        archetype_id   = "py_quarantine"
        parameters     = {}
        access_control = {}
      }
    }
  }
}
