locals {
  # Module version
  module_version = "1.0.0"

  # Common tags
  common_tags = {
    Module    = "azure-waf-policy"
    Version   = local.module_version
    ManagedBy = "terraform"
    CreatedBy = var.created_by != null ? var.created_by : "terraform"
  }

  # Resource naming
  waf_policy_name = var.waf_policy_name != null ? var.waf_policy_name : "${var.name_prefix}-waf-policy"

  # Merge common tags with custom tags
  tags = merge(local.common_tags, var.tags)
}
