provider "azurerm" {
  version = ">= 2.31.1"
  features {}
}

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "0.0.6-preview"

  # Mandatory Variables
  root_parent_id = var.tenant_id

  # Optional Variables
  root_id                   = local.root_id      // This string variable is used for the root Management Group ID and as a prefix for all core Management Group IDs
  root_name                 = local.root_name    // This string variable is used as a friendly name for the root Management Group
  deploy_core_landing_zones = true               // Control whether to deploy the default core landing zones // default = true
  deploy_demo_landing_zones = false              // Control whether to deploy the demo landing zones (default = false)
  library_path              = "${path.root}/lib" // This string variable is used to define the location of your custom library

  custom_landing_zones = {
    ycc-platform = {
      display_name               = "YCC Core"
      parent_management_group_id = local.root_id
      subscription_ids           = []

      archetype_config = {
        archetype_id   = "ycc_platform"
        parameters     = {}
        access_control = {}
      }
    }

    ycc-identity = {
      display_name               = "YCC Identity"
      parent_management_group_id = "${local.root_id}-platform"
      subscription_ids           = []

      archetype_config = {
        archetype_id   = "ycc_platform"
        parameters     = {}
        access_control = {}
      }
    }

    ycc-connectivity = {
      display_name               = "YCC Connectivity"
      parent_management_group_id = "${local.root_id}-platform"
      subscription_ids           = []

      archetype_config = {
        archetype_id   = "ycc_platform"
        parameters     = {}
        access_control = {}
      }
    }

    ycc-management = {
      display_name               = "YCC Management"
      parent_management_group_id = "${local.root_id}-platform"
      subscription_ids           = var.management_subscriptions

      archetype_config = {
        archetype_id   = "ycc_platform"
        parameters     = {}
        access_control = {}
      }
    }

    ycc-landing-zones = {
      display_name               = "YCC Baseline"
      parent_management_group_id = local.root_id
      subscription_ids           = []

      archetype_config = {
        archetype_id   = "ycc_landing_zone"
        parameters     = {}
        access_control = {}
      }
    }

    ycc-secure-research = {
      display_name               = "YCC Secure Research"
      parent_management_group_id = "${local.root_id}-landing-zones"
      subscription_ids           = var.secure_research_subscriptions

      archetype_config = {
        archetype_id   = "ycc_secure_research"
        parameters     = {
          YCC-Audit-NIST-800-171 = {
            logAnalyticsWorkspaceIDForVMAgents = "d6496211-ccd8-406a-9125-5b910da8a301"
          }
        }
        access_control = {}
      }
    }

    ycc-sandboxes = {
      display_name               = "YCC Sandbox"
      parent_management_group_id = local.root_id
      subscription_ids           = []

      archetype_config = {
        archetype_id   = "ycc_sandbox"
        parameters     = {}
        access_control = {}
      }
    }

    ycc-legacy = {
      display_name               = "YCC Legacy"
      parent_management_group_id = local.root_id
      subscription_ids           = []

      archetype_config = {
        archetype_id   = "ycc_legacy"
        parameters     = {}
        access_control = {}
      }
    }

    ycc-qurantine = {
      display_name               = "YCC Quarantine"
      parent_management_group_id = local.root_id
      subscription_ids           = []

      archetype_config = {
        archetype_id   = "ycc_quarantine"
        parameters     = {}
        access_control = {}
      }
    }

    ycc-decommissioned = {
      display_name               = "YCC Decommissioned"
      parent_management_group_id = local.root_id
      subscription_ids           = []

      archetype_config = {
        archetype_id   = "ycc-decommissioned"
        parameters     = {}
        access_control = {}
      }
    }
  }

  archetype_config_overrides = {
    root = {
      archetype_id = "ycc_root"
      parameters = {
        ES-Allowed-Locations = {
          listOfAllowedLocations = [
            "westus2",
            "westcentralus"
          ]
        }

        ES-Allowed-RSG-Locations = {
          listOfAllowedLocations = [
            "westus2",
            "westcentralus"
          ]
        }
      }
      access_control = {}
    }
  }
}