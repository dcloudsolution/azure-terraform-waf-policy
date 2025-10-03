variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the WAF policy will be created"
  type        = string
}

variable "waf_policy_name" {
  description = "Name of the WAF policy. If not provided, will be generated using name_prefix"
  type        = string
  default     = null
}

variable "policy_mode" {
  description = "The policy mode for the WAF policy"
  type        = string
  default     = "Prevention"
  validation {
    condition     = contains(["Detection", "Prevention"], var.policy_mode)
    error_message = "Policy mode must be either 'Detection' or 'Prevention'."
  }
}

variable "policy_enabled" {
  description = "Whether the WAF policy is enabled"
  type        = bool
  default     = true
}

variable "custom_rules" {
  description = "List of custom rules for the WAF policy"
  type = list(object({
    name      = string
    priority  = number
    rule_type = string
    action    = string
    match_conditions = list(object({
      match_variables = list(object({
        variable_name = string
        selector      = optional(string)
      }))
      operator           = string
      negation_condition = optional(bool)
      match_values       = list(string)
      transforms         = optional(list(string))
    }))
  }))
  default = []
}

variable "managed_rules" {
  description = "List of managed rule sets for the WAF policy"
  type = list(object({
    type    = string
    version = string
    rule_group_overrides = optional(list(object({
      rule_group_name = string
      rules = optional(list(object({
        rule_id = string
        enabled = bool
        action  = optional(string)
      })))
    })))
  }))
  default = [
    {
      type    = "OWASP"
      version = "3.2"
    }
  ]
}

variable "policy_settings" {
  description = "Policy settings for the WAF policy"
  type = object({
    enabled                          = optional(bool, true)
    mode                             = optional(string, "Prevention")
    request_body_check               = optional(bool, true)
    file_upload_limit_in_mb          = optional(number, 100)
    max_request_body_size_in_kb      = optional(number, 128)
    request_body_inspect_limit_in_kb = optional(number, 128)
    log_scrubbing_enabled            = optional(bool, false)
    log_scrubbing_rules = optional(list(object({
      match_variable          = string
      selector                = optional(string)
      selector_match_operator = optional(string)
      state                   = string
    })), [])
  })
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "created_by" {
  description = "Name of the person or system that created this resource"
  type        = string
  default     = null
}

variable "waf_policy" {
  description = "WAF policy configuration"
  type = map(object({
    name_prefix         = string
    resource_group_name = string
    location            = string
    waf_policy_name     = optional(string)
    policy_mode         = optional(string, "Prevention")
    policy_enabled      = optional(bool, true)
    custom_rules = optional(list(object({
      name      = string
      priority  = number
      rule_type = string
      action    = string
      match_conditions = list(object({
        match_variables = list(object({
          variable_name = string
          selector      = optional(string)
        }))
        operator           = string
        negation_condition = optional(bool)
        match_values       = list(string)
        transforms         = optional(list(string))
      }))
    })), [])
    managed_rules = optional(list(object({
      type    = string
      version = string
      rule_group_overrides = optional(list(object({
        rule_group_name = string
        rules = optional(list(object({
          rule_id = string
          enabled = bool
          action  = optional(string)
        })))
      })))
    })), [])
    policy_settings = optional(object({
      enabled                          = optional(bool, true)
      mode                             = optional(string, "Prevention")
      request_body_check               = optional(bool, true)
      file_upload_limit_in_mb          = optional(number, 100)
      max_request_body_size_in_kb      = optional(number, 128)
      request_body_inspect_limit_in_kb = optional(number, 128)
      log_scrubbing_enabled            = optional(bool, false)
      log_scrubbing_rules = optional(list(object({
        match_variable          = string
        selector                = optional(string)
        selector_match_operator = optional(string)
        state                   = string
      })), [])
    }), {})
    tags       = optional(map(string), {})
    created_by = optional(string)
  }))
  default = {}
}

