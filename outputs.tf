output "waf_policies" {
  description = "Complete map of WAF policy resources, keyed by policy name"
  value = {
    for k, v in azurerm_web_application_firewall_policy.main : k => {
      id                  = v.id
      name                = v.name
      location            = v.location
      resource_group_name = v.resource_group_name
      guid                = v.guid
      tags                = v.tags
    }
  }
}

output "module_version" {
  description = "The version of this module"
  value       = local.module_version
}
