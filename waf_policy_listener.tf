resource "azurerm_web_application_firewall_policy" "this" {
  provider = azurerm.app_gw
  for_each = var.waf_policy

  name                = "${var.waf_policy_name}-policy"
  resource_group_name = var.resource_group_name
  location            = var.location

  policy_settings {
    enabled                                   = true
    mode                                      = var.policy_settings.mode
    request_body_check                        = var.policy_settings.request_body_check
    file_upload_limit_in_mb                   = var.policy_settings.file_upload_limit_in_mb
    max_request_body_size_in_kb               = var.policy_settings.max_request_body_size_in_kb
    request_body_enforcement                  = var.policy_settings.request_body_enforcement
    request_body_inspect_limit_in_kb          = var.policy_settings.request_body_inspect_limit_in_kb
    js_challenge_cookie_expiration_in_minutes = var.policy_settings.js_challenge_cookie_expiration_in_minutes
    file_upload_enforcement                   = var.policy_settings.file_upload_enforcement

    log_scrubbing {
      enabled = var.policy_settings.log_scrubbing_enabled
    }
  }

  dynamic "managed_rules" {
    for_each = var.waf_policy[each.key].managed_rules != null ? [var.waf_policy[each.key].managed_rules] : []
    content {
      dynamic "exclusion" {
        for_each = managed_rules.value.exclusions != null ? [managed_rules.value.exclusions] : []
        content {
          match_variable          = exclusion.value.match_variable
          selector                = exclusion.value.selector
          selector_match_operator = exclusion.value.selector_match_operator
          excluded_rule_set {
            type    = exclusion.value.excluded_rule_set.type
            version = exclusion.value.excluded_rule_set.version
            rule_group {
              rule_group_name = exclusion.value.excluded_rule_set.rule_group.rule_group_name
              dynamic "excluded_rules" {
                for_each = exclusion.value.excluded_rule_set.rule_group.excluded_rules
                content {
                  rule_id = excluded_rules.value.rule_id
                }
              }
            }
          }
        }
      }

      dynamic "managed_rule_set" {
        for_each = managed_rules.value.managed_rule_sets != null ? [managed_rules.value.managed_rule_sets] : []
        content {
          type    = managed_rule_set.value.type
          version = managed_rule_set.value.version
          dynamic "rule_group_override" {
            for_each = managed_rule_set.value.rule_group_overrides != null ? [managed_rule_set.value.rule_group_overrides] : []
            content {
              rule_group_name = rule_group_override.value.rule_group_name
              dynamic "rule" {
                for_each = rule_group_override.value.rules != null ? [rule_group_override.value.rules] : []
                content {
                  id      = rule.value.id
                  enabled = rule.value.enabled
                  action  = rule.value.action
                  dynamic "exclusion" {
                    for_each = rule.value.exclusions != null ? [rule.value.exclusions] : []
                    content {
                      match_variable          = exclusion.value.match_variable
                      selector                = exclusion.value.selector
                      selector_match_operator = exclusion.value.selector_match_operator
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  dynamic "custom_rules" {
    for_each = var.waf_policy[each.key].custom_rules != null ? [var.waf_policy[each.key].custom_rules] : []
    content {
      name      = custom_rules.value.name
      priority  = custom_rules.value.priority
      rule_type = custom_rules.value.rule_type
      action    = custom_rules.value.action
      enabled   = custom_rules.value.enabled
      dynamic "match_conditions" {
        for_each = custom_rules.value.match_conditions != null ? [custom_rules.value.match_conditions] : []
        content {
          match_variables {
            variable_name = match_conditions.value.match_variables.variable_name
            selector      = match_conditions.value.match_variables.selector
          }
          operator           = match_conditions.value.operator
          negation_condition = match_conditions.value.negation_condition
          match_values       = match_conditions.value.match_values
          transforms         = match_conditions.value.transforms
        }
      }
    }
  }

  tags = merge(var.waf_policy[each.key].tags, var.tags)
}
