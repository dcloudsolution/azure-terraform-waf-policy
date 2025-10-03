resource "azurerm_web_application_firewall_policy" "main" {
  name                = var.waf_policy_name
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = local.tags

  # Policy settings - Only parameters supported by WAF policy resource
  dynamic "policy_settings" {
    for_each = var.policy_settings != null ? [var.policy_settings] : []
    content {
      enabled                          = policy_settings.value.enabled
      mode                             = policy_settings.value.mode
      request_body_check               = policy_settings.value.request_body_check
      file_upload_limit_in_mb          = policy_settings.value.file_upload_limit_in_mb
      max_request_body_size_in_kb      = policy_settings.value.max_request_body_size_in_kb
      request_body_inspect_limit_in_kb = policy_settings.value.request_body_inspect_limit_in_kb
      log_scrubbing {
        enabled = policy_settings.value.log_scrubbing_enabled
        dynamic "scrubbing_rules" {
          for_each = policy_settings.value.log_scrubbing_rules != null ? policy_settings.value.log_scrubbing_rules : []
          content {
            match_variable          = scrubbing_rules.value.match_variable
            selector                = scrubbing_rules.value.selector
            selector_match_operator = scrubbing_rules.value.selector_match_operator
            state                   = scrubbing_rules.value.state
          }
        }
      }
    }
  }

  # Custom rules - Only parameters supported by WAF policy resource
  dynamic "custom_rules" {
    for_each = var.custom_rules
    content {
      name      = custom_rules.value.name
      priority  = custom_rules.value.priority
      rule_type = custom_rules.value.rule_type
      action    = custom_rules.value.action

      dynamic "match_conditions" {
        for_each = custom_rules.value.match_conditions
        content {
          dynamic "match_variables" {
            for_each = match_conditions.value.match_variables
            content {
              variable_name = match_variables.value.variable_name
              selector      = match_variables.value.selector
            }
          }
          operator           = match_conditions.value.operator
          negation_condition = match_conditions.value.negation_condition
          match_values       = match_conditions.value.match_values
          transforms         = match_conditions.value.transforms
        }
      }
    }
  }

  # Managed rules - Only parameters supported by WAF policy resource
  dynamic "managed_rules" {
    for_each = var.managed_rules
    content {
      dynamic "managed_rule_set" {
        for_each = [managed_rules.value]
        content {
          type    = managed_rule_set.value.type
          version = managed_rule_set.value.version

          dynamic "rule_group_override" {
            for_each = managed_rule_set.value.rule_group_overrides != null ? managed_rule_set.value.rule_group_overrides : []
            content {
              rule_group_name = rule_group_override.value.rule_group_name

              dynamic "rule" {
                for_each = rule_group_override.value.rules != null ? rule_group_override.value.rules : []
                content {
                  id      = rule.value.rule_id
                  enabled = rule.value.enabled
                  action  = rule.value.action
                }
              }
            }
          }
        }
      }
    }
  }
}
