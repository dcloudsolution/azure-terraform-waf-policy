# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "test"
    Project     = "terratest"
    Owner       = "terratest"
  }
}

# Use the WAF policy module
module "waf_policy" {
  source = "../../.."

  name_prefix         = var.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location           = var.location
  waf_policy_name    = var.waf_policy_name

  # Use default managed rules (OWASP 3.2)
  managed_rules = [
    {
      type    = "OWASP"
      version = "3.2"
    }
  ]

  tags = var.tags
}
