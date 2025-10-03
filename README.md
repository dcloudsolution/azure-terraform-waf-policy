# Azure Web Application Firewall (WAF) Policy Terraform Module

This Terraform module creates an Azure Web Application Firewall (WAF) policy using the `azurerm_web_application_firewall_policy` resource. The module is designed to be flexible and configurable while providing sensible defaults.

## Features

- Creates Azure WAF policy with configurable settings
- Supports custom rules and managed rule sets
- Configurable policy settings (mode, request body check, file upload limits)
- Flexible tagging system
- Comprehensive outputs for integration with other modules

## Usage

### Basic Usage

```hcl
module "waf_policy" {
  source = "./"

  name_prefix         = "myapp"
  resource_group_name = "my-resource-group"
  location           = "East US"
}
```

### Advanced Usage with Custom Rules

```hcl
module "waf_policy" {
  source = "."

  name_prefix         = "myapp"
  resource_group_name = "my-resource-group"
  location           = "East US"
  
  policy_mode = "Prevention"
  
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
    }
  ]
  
  managed_rules = [
    {
      type    = "OWASP"
      version = "3.2"
      rule_group_overrides = [
        {
          rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
          rules = [
            {
              rule_id = "920300"
              enabled = false
            }
          ]
        }
      ]
    }
  ]
  
  policy_settings = {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }
  
  tags = {
    Environment = "production"
    Project     = "myproject"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for resource naming | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region where the WAF policy will be created | `string` | n/a | yes |
| waf_policy_name | Name of the WAF policy. If not provided, will be generated using name_prefix | `string` | `null` | no |
| policy_mode | The policy mode for the WAF policy | `string` | `"Prevention"` | no |
| policy_enabled | Whether the WAF policy is enabled | `bool` | `true` | no |
| custom_rules | List of custom rules for the WAF policy | `list(object)` | `[]` | no |
| managed_rules | List of managed rule sets for the WAF policy | `list(object)` | `[{"type": "OWASP", "version": "3.2"}]` | no |
| policy_settings | Policy settings for the WAF policy | `object` | `{}` | no |
| tags | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| created_by | Name of the person or system that created this resource | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| waf_policy_id | The ID of the Web Application Firewall Policy |
| waf_policy_name | The name of the Web Application Firewall Policy |
| waf_policy_location | The location of the Web Application Firewall Policy |
| waf_policy_resource_group_name | The resource group name of the Web Application Firewall Policy |
| waf_policy_guid | The GUID of the Web Application Firewall Policy |
| waf_policy_tags | The tags assigned to the Web Application Firewall Policy |
| module_version | The version of this module |

## Custom Rules Structure

Custom rules allow you to create your own rules for the WAF policy. Each custom rule has the following structure:

```hcl
{
  name     = "RuleName"
  priority = 1
  rule_type = "MatchRule"  # or "RateLimitRule"
  action   = "Block"       # or "Allow", "Log", "Redirect"
  match_conditions = [
    {
      match_variables = [
        {
          variable_name = "RemoteAddr"  # or other variables
          selector      = "optional"    # optional selector
        }
      ]
      operator           = "IPMatch"    # or other operators
      negation_condition = false
      match_values       = ["192.168.1.0/24"]
      transforms         = []           # optional transforms
    }
  ]
}
```

## Managed Rules

The module supports managed rule sets like OWASP. You can override specific rules within rule groups:

```hcl
{
  type    = "OWASP"
  version = "3.2"
  rule_group_overrides = [
    {
      rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
      rules = [
        {
          rule_id = "920300"
          enabled = false
          action  = "Block"  # optional
        }
      ]
    }
  ]
}
```

## Policy Settings

Configure global policy settings:

```hcl
{
  enabled                     = true
  mode                        = "Prevention"  # or "Detection"
  request_body_check          = true
  file_upload_limit_in_mb     = 100
  max_request_body_size_in_kb = 128
}
```

## Examples

### Basic WAF Policy
```hcl
module "basic_waf" {
  source = "./modules/azure_waf"
  
  name_prefix         = "basic"
  resource_group_name = "rg-basic"
  location           = "East US"
}
```

### WAF Policy with Custom Rules
```hcl
module "custom_waf" {
  source = "./modules/azure_waf"
  
  name_prefix         = "custom"
  resource_group_name = "rg-custom"
  location           = "East US"
  
  custom_rules = [
    {
      name     = "BlockBadBots"
      priority = 1
      rule_type = "MatchRule"
      action   = "Block"
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
          match_values       = ["badbot", "scanner"]
          transforms         = ["Lowercase"]
        }
      ]
    }
  ]
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Related documentation
Microsoft Azure documentation: docs.microsoft.com/en-us/azure/application-gateway/overview
<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | ~> 3.0 |

#### Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | ~> 3.0 |
| <a name="provider_azurerm.app_gw"></a> [azurerm.app_gw](#provider_azurerm.app_gw) | ~> 3.0 |

#### Resources

| Name | Type |
|------|------|
| [azurerm_web_application_firewall_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy) | resource |
| [azurerm_web_application_firewall_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy) | resource |

#### Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| <a name="input_created_by"></a> [created_by](#input_created_by) | Name of the person or system that created this resource | `string` | no |
| <a name="input_custom_rules"></a> [custom_rules](#input_custom_rules) | List of custom rules for the WAF policy | <pre>list(object({<br/>    name      = string<br/>    priority  = number<br/>    rule_type = string<br/>    action    = string<br/>    match_conditions = list(object({<br/>      match_variables = list(object({<br/>        variable_name = string<br/>        selector      = optional(string)<br/>      }))<br/>      operator           = string<br/>      negation_condition = optional(bool)<br/>      match_values       = list(string)<br/>      transforms         = optional(list(string))<br/>    }))<br/>  }))</pre> | no |
| <a name="input_location"></a> [location](#input_location) | Azure region where the WAF policy will be created | `string` | yes |
| <a name="input_managed_rules"></a> [managed_rules](#input_managed_rules) | List of managed rule sets for the WAF policy | <pre>list(object({<br/>    type    = string<br/>    version = string<br/>    rule_group_overrides = optional(list(object({<br/>      rule_group_name = string<br/>      rules = optional(list(object({<br/>        rule_id = string<br/>        enabled = bool<br/>        action  = optional(string)<br/>      })))<br/>    })))<br/>  }))</pre> | no |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix) | Prefix for resource naming | `string` | yes |
| <a name="input_policy_enabled"></a> [policy_enabled](#input_policy_enabled) | Whether the WAF policy is enabled | `bool` | no |
| <a name="input_policy_mode"></a> [policy_mode](#input_policy_mode) | The policy mode for the WAF policy | `string` | no |
| <a name="input_policy_settings"></a> [policy_settings](#input_policy_settings) | Policy settings for the WAF policy | <pre>object({<br/>    enabled                          = optional(bool, true)<br/>    mode                             = optional(string, "Prevention")<br/>    request_body_check               = optional(bool, true)<br/>    file_upload_limit_in_mb          = optional(number, 100)<br/>    max_request_body_size_in_kb      = optional(number, 128)<br/>    request_body_inspect_limit_in_kb = optional(number, 128)<br/>    log_scrubbing_enabled            = optional(bool, false)<br/>    log_scrubbing_rules = optional(list(object({<br/>      match_variable          = string<br/>      selector                = optional(string)<br/>      selector_match_operator = optional(string)<br/>      state                   = string<br/>    })), [])<br/>  })</pre> | no |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Name of the resource group | `string` | yes |
| <a name="input_tags"></a> [tags](#input_tags) | A mapping of tags to assign to the resource | `map(string)` | no |
| <a name="input_waf_policy"></a> [waf_policy](#input_waf_policy) | WAF policy configuration | <pre>map(object({<br/>    name_prefix         = string<br/>    resource_group_name = string<br/>    location            = string<br/>    waf_policy_name     = optional(string)<br/>    policy_mode         = optional(string, "Prevention")<br/>    policy_enabled      = optional(bool, true)<br/>    custom_rules = optional(list(object({<br/>      name      = string<br/>      priority  = number<br/>      rule_type = string<br/>      action    = string<br/>      match_conditions = list(object({<br/>        match_variables = list(object({<br/>          variable_name = string<br/>          selector      = optional(string)<br/>        }))<br/>        operator           = string<br/>        negation_condition = optional(bool)<br/>        match_values       = list(string)<br/>        transforms         = optional(list(string))<br/>      }))<br/>    })), [])<br/>    managed_rules = optional(list(object({<br/>      type    = string<br/>      version = string<br/>      rule_group_overrides = optional(list(object({<br/>        rule_group_name = string<br/>        rules = optional(list(object({<br/>          rule_id = string<br/>          enabled = bool<br/>          action  = optional(string)<br/>        })))<br/>      })))<br/>    })), [])<br/>    policy_settings = optional(object({<br/>      enabled                          = optional(bool, true)<br/>      mode                             = optional(string, "Prevention")<br/>      request_body_check               = optional(bool, true)<br/>      file_upload_limit_in_mb          = optional(number, 100)<br/>      max_request_body_size_in_kb      = optional(number, 128)<br/>      request_body_inspect_limit_in_kb = optional(number, 128)<br/>      log_scrubbing_enabled            = optional(bool, false)<br/>      log_scrubbing_rules = optional(list(object({<br/>        match_variable          = string<br/>        selector                = optional(string)<br/>        selector_match_operator = optional(string)<br/>        state                   = string<br/>      })), [])<br/>    }), {})<br/>    tags       = optional(map(string), {})<br/>    created_by = optional(string)<br/>  }))</pre> | no |
| <a name="input_waf_policy_name"></a> [waf_policy_name](#input_waf_policy_name) | Name of the WAF policy. If not provided, will be generated using name_prefix | `string` | no |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_module_version"></a> [module_version](#output_module_version) | The version of this module |
| <a name="output_waf_policies"></a> [waf_policies](#output_waf_policies) | Complete map of WAF policy resources, keyed by policy name |
<!-- END_TF_DOCS -->