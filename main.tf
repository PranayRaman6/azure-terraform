terraform {
  required_providers {
    azure = {
      source  = "hashicorp/azurerm"
      version = "=2.20.0"
    }
  }

  backend "remote" {
    organization = "pauldotyu"

    workspaces {
      name = "azure-terraform"
    }
  }
}

provider "azurerm" {
  version = "=2.20.0"
  features {}
}

data "azurerm_management_group" "prod_root" {
  name = var.root
}

resource "azurerm_management_group" "prod_main" {
  display_name               = "Main"
  parent_management_group_id = data.azurerm_management_group.prod_root.id
}

resource "azurerm_management_group" "prod_platform" {
  display_name               = "Platform"
  parent_management_group_id = azurerm_management_group.prod_main.id

  # subscription_ids = [
  #   var.prod_platform_sub,
  # ]
}

resource "azurerm_management_group" "prod_landingzone" {
  display_name               = "Landing Zone"
  parent_management_group_id = azurerm_management_group.prod_main.id

  subscription_ids = [
    var.prod_landingzone_sub,
  ]
}

resource "azurerm_management_group" "dev_sandbox" {
  display_name               = "Sandbox"
  parent_management_group_id = azurerm_management_group.prod_main.id
}

resource "azurerm_management_group" "prod_legacy" {
  display_name               = "Legacy"
  parent_management_group_id = azurerm_management_group.prod_main.id
}

resource "azurerm_management_group" "prod_quarantine" {
  display_name               = "Quarantine"
  parent_management_group_id = azurerm_management_group.prod_main.id
}

resource "azurerm_policy_definition" "main_req_rg_tags" {
  name                  = "requiredResourceGroupTags"
  policy_type           = "Custom"
  mode                  = "All"
  display_name          = "Required tags for resource groups"
  description           = "Denies any resource group deployments that do not have the required tags."
  management_group_name = azurerm_management_group.prod_main.name

  metadata = <<METADATA
    {
      "version": "1.0.0",
      "category": "Tags"
    }
  METADATA

  policy_rule = <<POLICY_RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Resources/subscriptions/resourceGroups"
          },
          {
            "anyOf": [
              {
                "field": "[concat('tags[', parameters('tagName1'), ']')]",
                "exists": "false"
              },
              {
                "field": "[concat('tags[', parameters('tagName2'), ']')]",
                "exists": "false"
              },
              {
                "field": "[concat('tags[', parameters('tagName2'), ']')]",
                "notIn": "[parameters('tagValue2')]"
              },
              {
                "field": "[concat('tags[', parameters('tagName3'), ']')]",
                "exists": "false"
              },
              {
                "field": "[concat('tags[', parameters('tagName3'), ']')]",
                "notIn": "[parameters('tagValue3')]"
              },
              {
                "field": "[concat('tags[', parameters('tagName4'), ']')]",
                "exists": "false"
              },
              {
                "field": "[concat('tags[', parameters('tagName4'), ']')]",
                "notIn": "[parameters('tagValue4')]"
              },
              {
                "field": "[concat('tags[', parameters('tagName5'), ']')]",
                "exists": "false"
              },
              {
                "field": "[concat('tags[', parameters('tagName5'), ']')]",
                "notIn": "[parameters('tagValue5')]"
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "deny"
      }
    }
  POLICY_RULE

  parameters = <<PARAMETERS
    {
      "tagName1": {
        "type": "String",
        "metadata": {
          "displayName": "PO Number Tag"
        },
        "defaultValue": "po-number"
      },
      "tagName2": {
        "type": "String",
        "metadata": {
          "displayName": "Environment Tag"
        },
        "defaultValue": "environment"
      },
      "tagValue2": {
        "type": "Array",
        "metadata": {
          "displayName": "Environment Tag Values",
          "description": "Approved values for the 'environment' tag, such as 'dev', 'test', 'prod'"
        },
        "allowedValues": [
          "dev",
          "test",
          "prod",
          "other"
        ],
        "defaultValue": [
          "dev",
          "test",
          "prod",
          "other"
        ]
      },
      "tagName3": {
        "type": "String",
        "metadata": {
          "displayName": "Mission Tag"
        },
        "defaultValue": "mission"
      },
      "tagValue3": {
        "type": "Array",
        "metadata": {
          "displayName": "Mission Tag Values",
          "description": "Approved values for the 'mission' tag, such as 'academic', 'research', 'administrative', 'mixed'"
        },
        "allowedValues": [
          "academic",
          "research",
          "administrative",
          "mixed"
        ],
        "defaultValue": [
          "academic",
          "research",
          "administrative",
          "mixed"
        ]
      },
      "tagName4": {
        "type": "String",
        "metadata": {
          "displayName": "Protection Level Tag"
        },
        "defaultValue": "protection-level"
      },
      "tagValue4": {
        "type": "Array",
        "metadata": {
          "displayName": "Protection Level Tag Values",
          "description": "Approved values for the 'protection-level' tag, such as 'p1', 'p2', 'p3', 'p4'"
        },
        "allowedValues": [
          "p1",
          "p2",
          "p3",
          "p4"
        ],
        "defaultValue": [
          "p1",
          "p2",
          "p3",
          "p4"
        ]
      },
      "tagName5": {
        "type": "String",
        "metadata": {
          "displayName": "Availability Level Tag"
        },
        "defaultValue": "availability-level"
      },
      "tagValue5": {
        "type": "Array",
        "metadata": {
          "displayName": "Availability Level Tag Values",
          "description": "Approved values for the 'availability-level' tag, such as 'a1', 'a2', 'a3', 'a4'"
        },
        "allowedValues": [
          "a1",
          "a2",
          "a3",
          "a4"
        ],
        "defaultValue": [
          "a1",
          "a2",
          "a3",
          "a4"
        ]
      }
    }
  PARAMETERS
}

resource "azurerm_policy_definition" "main_req_tags" {
  name                  = "requiredResourceTags"
  policy_type           = "Custom"
  mode                  = "Indexed"
  display_name          = "Required tags for resources that support tagging"
  description           = "Denies any resource deployments that do not have the required tags. This only applies to resources that support tagging."
  management_group_name = azurerm_management_group.prod_main.name

  metadata = <<METADATA
    {
      "version": "1.0.0",
      "category": "Tags"
    }
  METADATA

  policy_rule = <<POLICY_RULE
    {
      "if": {
        "anyOf": [
          {
            "field": "[concat('tags[', parameters('tagName1'), ']')]",
            "exists": "false"
          },
          {
            "field": "[concat('tags[', parameters('tagName2'), ']')]",
            "exists": "false"
          },
          {
            "field": "[concat('tags[', parameters('tagName2'), ']')]",
            "notIn": "[parameters('tagValue2')]"
          },
          {
            "field": "[concat('tags[', parameters('tagName3'), ']')]",
            "exists": "false"
          },
          {
            "field": "[concat('tags[', parameters('tagName3'), ']')]",
            "notIn": "[parameters('tagValue3')]"
          },
          {
            "field": "[concat('tags[', parameters('tagName4'), ']')]",
            "exists": "false"
          },
          {
            "field": "[concat('tags[', parameters('tagName4'), ']')]",
            "notIn": "[parameters('tagValue4')]"
          },
          {
            "field": "[concat('tags[', parameters('tagName5'), ']')]",
            "exists": "false"
          },
          {
            "field": "[concat('tags[', parameters('tagName5'), ']')]",
            "notIn": "[parameters('tagValue5')]"
          }
        ]
      },
      "then": {
        "effect": "deny"
      }
    }
  POLICY_RULE

  parameters = <<PARAMETERS
    {
      "tagName1": {
        "type": "String",
        "metadata": {
          "displayName": "PO Number Tag"
        },
        "defaultValue": "po-number"
      },
      "tagName2": {
        "type": "String",
        "metadata": {
          "displayName": "Environment Tag"
        },
        "defaultValue": "environment"
      },
      "tagValue2": {
        "type": "Array",
        "metadata": {
          "displayName": "Environment Tag Values",
          "description": "Approved values for the 'environment' tag, such as 'dev', 'test', 'prod'"
        },
        "allowedValues": [
          "dev",
          "test",
          "prod",
          "other"
        ],
        "defaultValue": [
          "dev",
          "test",
          "prod",
          "other"
        ]
      },
      "tagName3": {
        "type": "String",
        "metadata": {
          "displayName": "Mission Tag"
        },
        "defaultValue": "mission"
      },
      "tagValue3": {
        "type": "Array",
        "metadata": {
          "displayName": "Mission Tag Values",
          "description": "Approved values for the 'mission' tag, such as 'academic', 'research', 'administrative', 'mixed'"
        },
        "allowedValues": [
          "academic",
          "research",
          "administrative",
          "mixed"
        ],
        "defaultValue": [
          "academic",
          "research",
          "administrative",
          "mixed"
        ]
      },
      "tagName4": {
        "type": "String",
        "metadata": {
          "displayName": "Protection Level Tag"
        },
        "defaultValue": "protection-level"
      },
      "tagValue4": {
        "type": "Array",
        "metadata": {
          "displayName": "Protection Level Tag Values",
          "description": "Approved values for the 'protection-level' tag, such as 'p1', 'p2', 'p3', 'p4'"
        },
        "allowedValues": [
          "p1",
          "p2",
          "p3",
          "p4"
        ],
        "defaultValue": [
          "p1",
          "p2",
          "p3",
          "p4"
        ]
      },
      "tagName5": {
        "type": "String",
        "metadata": {
          "displayName": "Availability Level Tag"
        },
        "defaultValue": "availability-level"
      },
      "tagValue5": {
        "type": "Array",
        "metadata": {
          "displayName": "Availability Level Tag Values",
          "description": "Approved values for the 'availability-level' tag, such as 'a1', 'a2', 'a3', 'a4'"
        },
        "allowedValues": [
          "a1",
          "a2",
          "a3",
          "a4"
        ],
        "defaultValue": [
          "a1",
          "a2",
          "a3",
          "a4"
        ]
      }
    }
  PARAMETERS
}

resource "azurerm_policy_definition" "main_no_public_blobs" {
  name                  = "noPublicBlobs"
  policy_type           = "Custom"
  mode                  = "Indexed"
  display_name          = "Storage accounts should not allow public Blobs"
  description           = "Ensure that storage accounts do not allow creation of public Blobs"
  management_group_name = azurerm_management_group.prod_main.name

  metadata = <<METADATA
    {
        "version": "1.0.0",
        "category": "Regulatory Compliance"
    }
  METADATA

  policy_rule = <<POLICY_RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Storage/storageAccounts"
          },
          {
            "field": "Microsoft.Storage/storageAccounts/allowBlobPublicAccess",
            "notEquals": "false"
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]"
      }
    }
  POLICY_RULE

  parameters = <<PARAMETERS
    {
      "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "The effect determines what happens when the policy rule is evaluated to match"
        },
        "allowedValues": [
          "Audit",
          "Deny",
          "Disabled"
        ],
        "defaultValue": "Audit"
      }
    }
  PARAMETERS
}

resource "azurerm_policy_set_definition" "main_base_policyset" {
  name                  = "basePolicySet"
  policy_type           = "Custom"
  display_name          = "Organization Policy Set"
  description           = "Organization's baseline policy set for all deployments in Azure."
  management_group_name = azurerm_management_group.prod_main.name

  metadata = <<METADATA
    {
      "version": "1.0.0",
      "category": "Organizational Policy"
    }
  METADATA

  parameters = <<PARAMETERS
    {
      "allowedLocations": {
          "type": "Array",
          "metadata": {
              "description": "The list of allowed locations for resources.",
              "displayName": "Allowed locations",
              "strongType": "location"
          }
      },
      "tagName1": {
        "type": "String",
        "metadata": {
          "displayName": "PO number tag name"
        },
        "defaultValue": "po-number"
      },
      "tagName2": {
        "type": "String",
        "metadata": {
          "displayName": "Environment tag name"
        },
        "defaultValue": "environment"
      },
      "tagValue2": {
        "type": "Array",
        "metadata": {
          "displayName": "Allowed environment tag values",
          "description": "Allowed values for the 'environment' tag, such as 'dev', 'test', 'prod'"
        },
        "allowedValues": [
          "dev",
          "test",
          "prod",
          "other"
        ],
        "defaultValue": [
          "dev",
          "test",
          "prod",
          "other"
        ]
      },
      "tagName3": {
        "type": "String",
        "metadata": {
          "displayName": "Mission tag name"
        },
        "defaultValue": "mission"
      },
      "tagValue3": {
        "type": "Array",
        "metadata": {
          "displayName": "Allowed mission tag values",
          "description": "Allowed values for the 'mission' tag, such as 'academic', 'research', 'administrative', 'mixed'"
        },
        "allowedValues": [
          "academic",
          "research",
          "administrative",
          "mixed"
        ],
        "defaultValue": [
          "academic",
          "research",
          "administrative",
          "mixed"
        ]
      },
      "tagName4": {
        "type": "String",
        "metadata": {
          "displayName": "Protection level tag name"
        },
        "defaultValue": "protection-level"
      },
      "tagValue4": {
        "type": "Array",
        "metadata": {
          "displayName": "Allowed protection level tag values",
          "description": "Allowed values for the 'protection-level' tag, such as 'p1', 'p2', 'p3', 'p4'"
        },
        "allowedValues": [
          "p1",
          "p2",
          "p3",
          "p4"
        ],
        "defaultValue": [
          "p1",
          "p2",
          "p3",
          "p4"
        ]
      },
      "tagName5": {
        "type": "String",
        "metadata": {
          "displayName": "Availability level tag name"
        },
        "defaultValue": "availability-level"
      },
      "tagValue5": {
        "type": "Array",
        "metadata": {
          "displayName": "Allowed availability level tag values",
          "description": "Allowed values for the 'availability-level' tag, such as 'a1', 'a2', 'a3', 'a4'"
        },
        "allowedValues": [
          "a1",
          "a2",
          "a3",
          "a4"
        ],
        "defaultValue": [
          "a1",
          "a2",
          "a3",
          "a4"
        ]
      },
      "publicBlobStorageEffect": {
        "type": "String",
        "metadata": {
          "description": "The effect determines what happens when the policy rule is evaluated to match",
          "displayName": "Public blob storage policy effect"
        },
        "allowedValues": [
          "Audit",
          "Deny",
          "Disabled"
        ],
        "defaultValue": "Deny"
      }
    }
  PARAMETERS

  # Allowed locations for resource groups
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988"
    parameters = {
      listOfAllowedLocations = "[parameters('allowedLocations')]"
    }
  }

  # Allowed locations for resources
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
    parameters = {
      listOfAllowedLocations = "[parameters('allowedLocations')]"
    }
  }

  # Required tags for resource groups
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.main_req_rg_tags.id
    parameters = {
      tagName1  = "[parameters('tagName1')]"
      tagName2  = "[parameters('tagName2')]"
      tagValue2 = "[parameters('tagValue2')]"
      tagName3  = "[parameters('tagName3')]"
      tagValue3 = "[parameters('tagValue3')]"
      tagName4  = "[parameters('tagName4')]"
      tagValue4 = "[parameters('tagValue4')]"
      tagName5  = "[parameters('tagName5')]"
      tagValue5 = "[parameters('tagValue5')]"
    }
  }

  # Required tags for resources
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.main_req_tags.id
    parameters = {
      tagName1  = "[parameters('tagName1')]"
      tagName2  = "[parameters('tagName2')]"
      tagValue2 = "[parameters('tagValue2')]"
      tagName3  = "[parameters('tagName3')]"
      tagValue3 = "[parameters('tagValue3')]"
      tagName4  = "[parameters('tagName4')]"
      tagValue4 = "[parameters('tagValue4')]"
      tagName5  = "[parameters('tagName5')]"
      tagValue5 = "[parameters('tagValue5')]"
    }
  }

  # Inherit a tag from the resource group if missing (po-number)
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
    parameters = {
      tagName = "[parameters('tagName1')]"
    }
  }

  # Inherit a tag from the resource group if missing (environment)
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
    parameters = {
      tagName = "[parameters('tagName2')]"
    }
  }

  # Inherit a tag from the resource group if missing (mission)
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
    parameters = {
      tagName = "[parameters('tagName3')]"
    }
  }

  # Inherit a tag from the resource group if missing (protection-level)
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
    parameters = {
      tagName = "[parameters('tagName4')]"
    }
  }

  # Inherit a tag from the resource group if missing (availability-level)
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
    parameters = {
      tagName = "[parameters('tagName5')]"
    }
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.main_no_public_blobs.id
    parameters = {
      effect = "[parameters('publicBlobStorageEffect')]"
    }
  }
}

resource "azurerm_policy_assignment" "main_base_policyset_assign" {
  name                 = "basePolicySetAssignment"
  scope                = azurerm_management_group.prod_main.id
  policy_definition_id = azurerm_policy_set_definition.main_base_policyset.id
  description          = "Organization policy Assignment for all Azure deployments"
  display_name         = "Organization policy Assignment"

  metadata = <<METADATA
    {
      "category": "General"
    }
  METADATA

  parameters = <<PARAMETERS
    {
      "allowedLocations": {
        "value": [ "West US 2", "West Central US", "Central US", "South Central US" ]
      }
    }
  PARAMETERS

  location = "westus2"

  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_policy_set_definition" "prod_policyset_nist" {
  name                  = var.prod_policyset_nist
  management_group_name = azurerm_management_group.prod_main.name
}

resource "azurerm_policy_assignment" "prod_policyset_nist_assign" {
  name                 = "nistPolicySetAssignment"
  scope                = azurerm_management_group.prod_main.id
  policy_definition_id = data.azurerm_policy_set_definition.prod_policyset_nist.id
  description          = "Custom NIST SP 800-171 R2 policy assignment for all Azure deployments"
  display_name         = "Custom NIST SP 800-171 R2 Policy Assignment"

  metadata = <<METADATA
    {
      "category": "Regulatory Compliance"
    }
  METADATA

  parameters = <<PARAMETERS
    {
      "membersToExcludeInLocalAdministratorsGroup": {
        "value": "${var.prod_policyset_nist_assign_exclude}"
      },
      "membersToIncludeInLocalAdministratorsGroup": {
        "value": "${var.prod_policyset_nist_assign_include}"
      },
      "listOfLocationsForNetworkWatcher": {
        "value": ["West US 2", "West Central US", "Central US", "South Central US"]
      },
      "logAnalyticsWorkspaceIDForVMAgents": {
        "value": "${var.prod_policyset_nist_assign_log_analytics}"
      }
    }
  PARAMETERS

  location = "westus2"

  identity {
    type = "SystemAssigned"
  }
}
