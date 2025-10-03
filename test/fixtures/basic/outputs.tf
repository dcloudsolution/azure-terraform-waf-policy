output "waf_policy_id" {
  description = "The ID of the Web Application Firewall Policy"
  value       = module.waf_policy.waf_policy_id
}

output "waf_policy_name" {
  description = "The name of the Web Application Firewall Policy"
  value       = module.waf_policy.waf_policy_name
}

output "waf_policy_location" {
  description = "The location of the Web Application Firewall Policy"
  value       = module.waf_policy.waf_policy_location
}

output "waf_policy_tags" {
  description = "The tags assigned to the Web Application Firewall Policy"
  value       = module.waf_policy.waf_policy_tags
}
