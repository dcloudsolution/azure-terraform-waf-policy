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

# Use the WAF policy module with custom policy settings
module "waf_policy" {
  source = "../../.."

  name_prefix         = var.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location           = var.location
  waf_policy_name    = var.waf_policy_name

  # Policy settings
  policy_settings = {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
    request_body_inspect_limit_in_kb = 128
    log_scrubbing_enabled       = true
    log_scrubbing_rules = [
      {
        match_variable           = "RequestHeaderNames"
        selector                 = "User-Agent"
        selector_match_operator  = "Equals"
        state                    = "Enabled"
      }
    ]
  }

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
