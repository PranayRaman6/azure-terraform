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

resource "azurerm_role_definition" "sub_owner" {
  name        = "Custom Subscription Owner"
  scope       = azurerm_management_group.prod_main.id
  description = "Grants full access to manage all resources, including the ability to assign roles in Azure RBAC except for VPN and ExpressRoute networking resources"

  permissions {
    actions = ["*"]
    not_actions = [
      "Microsoft.Network/vpnGateways/*",
      "Microsoft.Network/expressRouteCircuits/*",
      "Microsoft.Network/vpnSites/*"
    ]
  }

  assignable_scopes = [ # /subscriptions/00000000-0000-0000-0000-000000000000
    azurerm_management_group.prod_main.id
  ]
}

resource "azurerm_role_definition" "app_owner" {
  name        = "Custom Application Owner"
  scope       = azurerm_management_group.prod_main.id
  description = "Contributor role granted for application/operations team at resource group level"

  permissions {
    actions = ["*"]
    not_actions = [
      "Microsoft.Authorization/*/write",
      "Microsoft.Network/vpnGateways/*",
      "Microsoft.Network/expressRouteCircuits/*",
      "Microsoft.Network/vpnSites/*",
      "Microsoft.Network/routeTables/write",
      "Microsoft.Network/publicIPAddresses/write",
      "Microsoft.Network/virtualNetworks/write",
      "Microsoft.KeyVault/locations/deletedVaults/purge/action"
    ]
  }

  assignable_scopes = [ # /subscriptions/00000000-0000-0000-0000-000000000000
    azurerm_management_group.prod_main.id
  ]
}

resource "azurerm_role_definition" "sec_op" {
  name        = "Custom Security Administrator"
  scope       = azurerm_management_group.prod_main.id
  description = "Security administrator role with a horizontal view across the entire Azure estate and the Azure Key Vault purge policy"

  permissions {
    actions = [
      "*/read",
      "*/register/action",
      "Microsoft.KeyVault/locations/deletedVaults/purge/action",
      "Microsoft.Insights/alertRules/*",
      "Microsoft.Authorization/policyDefinitions/*",
      "Microsoft.Authorization/policyAssignments/*",
      "Microsoft.Authorization/policySetDefinitions/*",
      "Microsoft.PolicyInsights/*",
      "Microsoft.Security/*"
    ]
    not_actions = []
  }

  assignable_scopes = [ # /subscriptions/00000000-0000-0000-0000-000000000000
    azurerm_management_group.prod_main.id
  ]
}

resource "azurerm_role_definition" "net_op" {
  name        = "Custom Network Administrator"
  scope       = azurerm_management_group.prod_main.id
  description = "Platform-wide global connectivity management: VNets, UDRs, NSGs, NVAs, VPN, ExpressRoute, and others"

  permissions {
    actions = [
      "*/read",
      "Microsoft.Authorization/*/write",
      "Microsoft.Network/vpnGateways/*",
      "Microsoft.Network/expressRouteCircuits/*",
      "Microsoft.Network/routeTables/write",
      "Microsoft.Network/vpnSites/*",
      "Microsoft.Resources/deployments/validate/*"
    ]
    not_actions = []
  }

  assignable_scopes = [ # /subscriptions/00000000-0000-0000-0000-000000000000
    azurerm_management_group.prod_main.id
  ]
}