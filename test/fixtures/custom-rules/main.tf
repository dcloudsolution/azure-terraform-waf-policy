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

# Use the WAF policy module with custom rules
module "waf_policy" {
  source = "../../.."

  name_prefix         = var.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location           = var.location
  waf_policy_name    = var.waf_policy_name

  # Custom rules
  custom_rules = [
    {
      name     = "BlockSuspiciousIPs"
      priority = 1
      rule_type = "MatchRule"
      action   = "Block"
      match_conditions = [
        {
          match_variables = [
            {
              variable_name = "RemoteAddr"
            }
          ]
          operator           = "IPMatch"
          negation_condition = false
          match_values       = ["192.168.1.0/24", "10.0.0.0/8"]
          transforms         = []
        }
      ]
    },
    {
      name     = "AllowGoodBots"
      priority = 2
      rule_type = "MatchRule"
      action   = "Allow"
      match_conditions = [
        {
          match_variables = [
            {
              variable_name = "RequestHeaders"
              selector      = "User-Agent"
            }
          ]
          operator           = "Contains"
          negation_condition = false
          match_values       = ["Googlebot", "Bingbot"]
          transforms         = ["Lowercase"]
        }
      ]
    }
  ]

  # Managed rules
  managed_rules = [
    {
      type    = "OWASP"
      version = "3.2"
    }
  ]

  tags = {
    Environment = "test"
    Project     = "terratest"
    Owner       = "terratest"
  }
}
