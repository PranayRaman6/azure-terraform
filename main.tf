terraform {
  backend "remote" {
    organization = "pauldotyu"

    workspaces {
      name = "azure-terraform"
    }
  }
}

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
  deploy_core_landing_zones = true                // Control whether to deploy the default core landing zones // default = true
  deploy_demo_landing_zones = false               // Control whether to deploy the demo landing zones (default = false)
  library_path              = "${path.root}/lib"  // Set a path for the custom archetype library path

  custom_landing_zones = {
    #------------------------------------------------------#
    # This variable is used to add new Landing Zones using
    # the Enterprise-scale deployment model.
    # Simply add new map items containing the required
    # attributes, and the Enterprise-scale core module will
    # take care of the rest.
    # To associated existing Management Groups which have
    # been imported using "terraform import ...", please ensure
    # the key matches the id (Name) of the imported Management
    # Group and ensure all other values match the existing
    # configuration.
    #------------------------------------------------------#
    customer-web-prod = {
      display_name               = "Prod Web Applications"
      parent_management_group_id = "tf-landing-zones"
      subscription_ids           = []
      archetype_config = {
        archetype_id = "customer_online"
        parameters   = {}
        access_control = {}
      }
    }
    customer-web-dev = {
      display_name               = "Dev Web Applications"
      parent_management_group_id = "tf-landing-zones"
      subscription_ids           = []
      archetype_config = {
        archetype_id = "customer_online"
        parameters = {}
        access_control = {}
      }
    }
    #------------------------------------------------------#
    # EXAMPLES
    #------------------------------------------------------#
    # example-mg = {
    #   display_name               = "Example Management Group"
    #   parent_management_group_id = "es-landing-zones"
    #   subscription_ids           = [
    #     "3117d098-8b43-433b-849d-b761742eb717",
    #   ]
    #   archetype_config = {
    #     archetype_id = "es_landing_zones"
    #     parameters = {
    #       policy_assignment_id = {
    #         param_name_1 = param_value_1
    #         param_name_2 = param_value_2
    #         param_name_3 = param_value_3
    #       }
    #     }
    #     access_control = {
    #       role_definition_name = {
    #         "member_1_object_id",
    #         "member_2_object_id",
    #         "member_3_object_id",
    #       }
    #     }
    #   }
    # }
    #------------------------------------------------------#
  }

  # The following var provides an example for how to specify
  # custom archetypes for the connectivity Landing Zones
  archetype_config_overrides = {
    #------------------------------------------------------#
    # This variable is used to configure the built-in
    # Enterprise-scale Management Groups with alternate
    # (or custom) name and parameters.
    # Simply uncomment the one(s) you want to modify and
    # provide the required values.
    #------------------------------------------------------#
    # root = {
    #   archetype_id   = "es_root"
    #   parameters     = {}
    #   access_control = {}
    # }
    # decommissioned = {
    #   archetype_id   = "es_decommissioned"
    #   parameters     = {}
    #   access_control = {}
    # }
    # sandboxes = {
    #   archetype_id   = "es_sandboxes"
    #   parameters     = {}
    #   access_control = {}
    # }
    # landing_zones = {
    #   archetype_id   = "es_landing_zones"
    #   parameters     = {}
    #   access_control = {}
    # }
    # platform = {
    #   archetype_id   = "es_platform"
    #   parameters     = {}
    #   access_control = {}
    # }
    # connectivity = {
    #   archetype_id   = "es_connectivity_foundation"
    #   parameters     = {}
    #   access_control = {}
    # }
    # management = {
    #   archetype_id   = "es_management"
    #   parameters     = {}
    #   access_control = {}
    # }
    # identity = {
    #   archetype_id   = "es_identity"
    #   parameters     = {}
    #   access_control = {}
    # }
    # demo_corp = {
    #   archetype_id   = "es_demo_corp"
    #   parameters     = {}
    #   access_control = {}
    # }
    # demo_online = {
    #   archetype_id   = "es_demo_online"
    #   parameters     = {}
    #   access_control = {}
    # }
    # demo_sap = {
    #   archetype_id   = "es_demo_sap"
    #   parameters     = {}
    #   access_control = {}
    # }
    #------------------------------------------------------#
    # EXAMPLES
    #------------------------------------------------------#
    # connectivity = {
    #   archetype_id = "es_connectivity_vwan"
    #   parameters = {
    #     policy_assignment_id = {
    #       param_name_1 = param_value_1
    #       param_name_2 = param_value_2
    #       param_name_3 = param_value_3
    #     }
    #   }
    #   access_control = {
    #     role_definition_name = {
    #       "member_1_object_id",
    #       "member_2_object_id",
    #       "member_3_object_id",
    #     }
    #   }
    # }
    #------------------------------------------------------#
  }

  subscription_id_overrides = {
    #------------------------------------------------------#
    # This variable is used to associate Azure subscription_ids
    # with the built-in Enterprise-scale Management Groups.
    # Simply add one or more Subscription IDs to any of the
    # built-in Management Groups listed below as required.
    #------------------------------------------------------#
    root           = []
    decommissioned = []
    sandboxes      = []
    landing-zones  = []
    platform       = []
    connectivity   = []
    management     = []
    identity       = []
    demo-corp      = []
    demo-online    = []
    demo-sap       = []
    #------------------------------------------------------#
    # EXAMPLES
    #------------------------------------------------------#
    # connectivity = [
    #   "3117d098-8b43-433b-849d-b761742eb717",
    # ]
    # management = [
    #   "9ee716a9-e411-433a-86ea-d82bf7b7ca61",
    # ]
    # identity = [
    #   "cae4c823-f353-4a34-a91a-acc5a0bd65c7",
    # ]
    #------------------------------------------------------#
  }
}