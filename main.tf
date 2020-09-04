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

  subscription_ids = [
    var.prod_platform_sub,
  ]
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

resource "azurerm_policy_definition" "main_req_tags" {
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
  name         = "basePolicySet"
  policy_type  = "Custom"
  display_name = "Baseline Policy Set"
  description  = "Organization's baseline policy set for all deployments in Azure."
  management_group_name = azurerm_management_group.prod_main.name

  parameters = <<PARAMETERS
    {
        "allowedLocations": {
            "type": "Array",
            "metadata": {
                "description": "The list of allowed locations for resources.",
                "displayName": "Allowed locations",
                "strongType": "location"
            }
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
}