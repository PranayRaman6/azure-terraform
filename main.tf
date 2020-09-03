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
}

resource "azurerm_management_group" "prod_landingzone" {
  display_name               = "Landing Zone"
  parent_management_group_id = azurerm_management_group.prod_main.id
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