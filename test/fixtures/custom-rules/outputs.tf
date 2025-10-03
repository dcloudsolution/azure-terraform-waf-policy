output "waf_policy_id" {
  description = "The ID of the Web Application Firewall Policy"
  value       = module.waf_policy.waf_policy_id
}

output "waf_policy_name" {
  description = "The name of the Web Application Firewall Policy"
  value       = module.waf_policy.waf_policy_name
}
