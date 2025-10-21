# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}



resource "random_password" "rg" {
  length  = 32
  special = true
  lower   = true
  upper   = true
  number  = true
}


locals {
  users = [
    [
      "juantenorio", 
      "Juan Tenorio",
      "juantenorio@accenture.com"
    ],
    [
      "ricardovilla",
      "Ricardo Villa Vicencio", 
      "villa@capgemini.com"
    ]
  ]
}






resource "azurerm_resource_group" "rg" {
  name     = "IDEA_TERRAFORM"
  location = "eastus"
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "idea_terraform"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azuread_user" "aplicaciones" {

  for_each = {for idx, user in local.users: idx => user}

  user_principal_name = "${each.value[0]}.tienda@mi-gran-idea.com"
  display_name        = each.value[1]
  mail_nickname       = each.value[0]
  password            = random_password.rg.result
}




data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "aplicaciones" {
}


resource "azurerm_role_assignment" "aplicaciones" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_client_config.aplicaciones.object_id
}


