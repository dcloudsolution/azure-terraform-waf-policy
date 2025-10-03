package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestWafPolicyBasic(t *testing.T) {
	t.Parallel()

	// Generate a random name for the resource group
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("terratest-waf-rg-%s", uniqueID)
	wafPolicyName := fmt.Sprintf("terratest-waf-policy-%s", uniqueID)

	// Configure Terraform options
	terraformOptions := &terraform.Options{
		// Path to the Terraform code
		TerraformDir: "../test/fixtures/basic",

		// Variables to pass to Terraform
		Vars: map[string]interface{}{
			"name_prefix":         "terratest",
			"resource_group_name": resourceGroupName,
			"location":            "East US",
			"waf_policy_name":     wafPolicyName,
		},

		// Retry up to 3 times on known errors
		MaxRetries:         3,
		TimeBetweenRetries: "5s",
		RetryableTerraformErrors: map[string]string{
			"ResourceInUse": "Resource is in use by another resource",
		},
	}

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Get the outputs
	wafPolicyID := terraform.Output(t, terraformOptions, "waf_policy_id")
	wafPolicyNameOutput := terraform.Output(t, terraformOptions, "waf_policy_name")
	wafPolicyLocation := terraform.Output(t, terraformOptions, "waf_policy_location")

	// Verify the WAF policy was created
	assert.NotEmpty(t, wafPolicyID, "WAF policy ID should not be empty")
	assert.Equal(t, wafPolicyName, wafPolicyNameOutput, "WAF policy name should match")
	assert.Equal(t, "East US", wafPolicyLocation, "WAF policy location should be East US")

	// Verify the WAF policy exists in Azure
	subscriptionID := azure.GetSubscriptionIDFromEnvVar(t)
	exists := azure.WafPolicyExists(t, wafPolicyName, resourceGroupName, subscriptionID)
	assert.True(t, exists, "WAF policy should exist in Azure")

	// Get the WAF policy details
	wafPolicy := azure.GetWafPolicy(t, wafPolicyName, resourceGroupName, subscriptionID)
	assert.NotNil(t, wafPolicy, "WAF policy should not be nil")
	assert.Equal(t, wafPolicyName, *wafPolicy.Name, "WAF policy name should match")
	assert.Equal(t, "East US", *wafPolicy.Location, "WAF policy location should match")
}

func TestWafPolicyWithCustomRules(t *testing.T) {
	t.Parallel()

	// Generate a random name for the resource group
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("terratest-waf-rg-%s", uniqueID)
	wafPolicyName := fmt.Sprintf("terratest-waf-policy-%s", uniqueID)

	// Configure Terraform options
	terraformOptions := &terraform.Options{
		// Path to the Terraform code
		TerraformDir: "../test/fixtures/custom-rules",

		// Variables to pass to Terraform
		Vars: map[string]interface{}{
			"name_prefix":         "terratest",
			"resource_group_name": resourceGroupName,
			"location":            "East US",
			"waf_policy_name":     wafPolicyName,
		},

		// Retry up to 3 times on known errors
		MaxRetries:         3,
		TimeBetweenRetries: "5s",
		RetryableTerraformErrors: map[string]string{
			"ResourceInUse": "Resource is in use by another resource",
		},
	}

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Get the outputs
	wafPolicyID := terraform.Output(t, terraformOptions, "waf_policy_id")
	wafPolicyNameOutput := terraform.Output(t, terraformOptions, "waf_policy_name")

	// Verify the WAF policy was created
	assert.NotEmpty(t, wafPolicyID, "WAF policy ID should not be empty")
	assert.Equal(t, wafPolicyName, wafPolicyNameOutput, "WAF policy name should match")

	// Verify the WAF policy exists in Azure
	subscriptionID := azure.GetSubscriptionIDFromEnvVar(t)
	exists := azure.WafPolicyExists(t, wafPolicyName, resourceGroupName, subscriptionID)
	assert.True(t, exists, "WAF policy should exist in Azure")

	// Get the WAF policy details
	wafPolicy := azure.GetWafPolicy(t, wafPolicyName, resourceGroupName, subscriptionID)
	assert.NotNil(t, wafPolicy, "WAF policy should not be nil")

	// Verify custom rules are present
	if wafPolicy.CustomRules != nil && len(*wafPolicy.CustomRules) > 0 {
		customRules := *wafPolicy.CustomRules
		assert.Greater(t, len(customRules), 0, "Custom rules should be present")

		// Check if our custom rule exists
		foundCustomRule := false
		for _, rule := range customRules {
			if rule.Name != nil && *rule.Name == "BlockSuspiciousIPs" {
				foundCustomRule = true
				assert.Equal(t, int32(1), *rule.Priority, "Custom rule priority should be 1")
				break
			}
		}
		assert.True(t, foundCustomRule, "Custom rule 'BlockSuspiciousIPs' should be present")
	}
}

func TestWafPolicyWithManagedRules(t *testing.T) {
	t.Parallel()

	// Generate a random name for the resource group
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("terratest-waf-rg-%s", uniqueID)
	wafPolicyName := fmt.Sprintf("terratest-waf-policy-%s", uniqueID)

	// Configure Terraform options
	terraformOptions := &terraform.Options{
		// Path to the Terraform code
		TerraformDir: "../test/fixtures/managed-rules",

		// Variables to pass to Terraform
		Vars: map[string]interface{}{
			"name_prefix":         "terratest",
			"resource_group_name": resourceGroupName,
			"location":            "East US",
			"waf_policy_name":     wafPolicyName,
		},

		// Retry up to 3 times on known errors
		MaxRetries:         3,
		TimeBetweenRetries: "5s",
		RetryableTerraformErrors: map[string]string{
			"ResourceInUse": "Resource is in use by another resource",
		},
	}

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Get the outputs
	wafPolicyID := terraform.Output(t, terraformOptions, "waf_policy_id")
	wafPolicyNameOutput := terraform.Output(t, terraformOptions, "waf_policy_name")

	// Verify the WAF policy was created
	assert.NotEmpty(t, wafPolicyID, "WAF policy ID should not be empty")
	assert.Equal(t, wafPolicyName, wafPolicyNameOutput, "WAF policy name should match")

	// Verify the WAF policy exists in Azure
	subscriptionID := azure.GetSubscriptionIDFromEnvVar(t)
	exists := azure.WafPolicyExists(t, wafPolicyName, resourceGroupName, subscriptionID)
	assert.True(t, exists, "WAF policy should exist in Azure")

	// Get the WAF policy details
	wafPolicy := azure.GetWafPolicy(t, wafPolicyName, resourceGroupName, subscriptionID)
	assert.NotNil(t, wafPolicy, "WAF policy should not be nil")

	// Verify managed rules are present
	if wafPolicy.ManagedRules != nil && len(*wafPolicy.ManagedRules) > 0 {
		managedRules := *wafPolicy.ManagedRules
		assert.Greater(t, len(managedRules), 0, "Managed rules should be present")

		// Check if OWASP rule set is present
		foundOWASP := false
		for _, ruleSet := range managedRules {
			if ruleSet.RuleSetType != nil && *ruleSet.RuleSetType == "OWASP" {
				foundOWASP = true
				break
			}
		}
		assert.True(t, foundOWASP, "OWASP managed rule set should be present")
	}
}

func TestWafPolicyTags(t *testing.T) {
	t.Parallel()

	// Generate a random name for the resource group
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("terratest-waf-rg-%s", uniqueID)
	wafPolicyName := fmt.Sprintf("terratest-waf-policy-%s", uniqueID)

	// Configure Terraform options
	terraformOptions := &terraform.Options{
		// Path to the Terraform code
		TerraformDir: "../test/fixtures/basic",

		// Variables to pass to Terraform
		Vars: map[string]interface{}{
			"name_prefix":         "terratest",
			"resource_group_name": resourceGroupName,
			"location":            "East US",
			"waf_policy_name":     wafPolicyName,
			"tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
				"Owner":       "terratest",
			},
		},

		// Retry up to 3 times on known errors
		MaxRetries:         3,
		TimeBetweenRetries: "5s",
		RetryableTerraformErrors: map[string]string{
			"ResourceInUse": "Resource is in use by another resource",
		},
	}

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Get the outputs
	wafPolicyTags := terraform.Output(t, terraformOptions, "waf_policy_tags")

	// Verify tags are present
	assert.NotEmpty(t, wafPolicyTags, "WAF policy tags should not be empty")
	assert.Contains(t, wafPolicyTags, "Environment", "WAF policy should have Environment tag")
	assert.Contains(t, wafPolicyTags, "Project", "WAF policy should have Project tag")
	assert.Contains(t, wafPolicyTags, "Owner", "WAF policy should have Owner tag")

	// Verify the WAF policy exists in Azure
	subscriptionID := azure.GetSubscriptionIDFromEnvVar(t)
	exists := azure.WafPolicyExists(t, wafPolicyName, resourceGroupName, subscriptionID)
	assert.True(t, exists, "WAF policy should exist in Azure")

	// Get the WAF policy details and verify tags
	wafPolicy := azure.GetWafPolicy(t, wafPolicyName, resourceGroupName, subscriptionID)
	assert.NotNil(t, wafPolicy, "WAF policy should not be nil")

	if wafPolicy.Tags != nil {
		tags := wafPolicy.Tags
		assert.Equal(t, "test", *tags["Environment"], "Environment tag should be 'test'")
		assert.Equal(t, "terratest", *tags["Project"], "Project tag should be 'terratest'")
		assert.Equal(t, "terratest", *tags["Owner"], "Owner tag should be 'terratest'")
	}
}

func TestWafPolicyPolicySettings(t *testing.T) {
	t.Parallel()

	// Generate a random name for the resource group
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("terratest-waf-rg-%s", uniqueID)
	wafPolicyName := fmt.Sprintf("terratest-waf-policy-%s", uniqueID)

	// Configure Terraform options
	terraformOptions := &terraform.Options{
		// Path to the Terraform code
		TerraformDir: "../test/fixtures/policy-settings",

		// Variables to pass to Terraform
		Vars: map[string]interface{}{
			"name_prefix":         "terratest",
			"resource_group_name": resourceGroupName,
			"location":            "East US",
			"waf_policy_name":     wafPolicyName,
		},

		// Retry up to 3 times on known errors
		MaxRetries:         3,
		TimeBetweenRetries: "5s",
		RetryableTerraformErrors: map[string]string{
			"ResourceInUse": "Resource is in use by another resource",
		},
	}

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Get the outputs
	wafPolicyID := terraform.Output(t, terraformOptions, "waf_policy_id")
	wafPolicyNameOutput := terraform.Output(t, terraformOptions, "waf_policy_name")

	// Verify the WAF policy was created
	assert.NotEmpty(t, wafPolicyID, "WAF policy ID should not be empty")
	assert.Equal(t, wafPolicyName, wafPolicyNameOutput, "WAF policy name should match")

	// Verify the WAF policy exists in Azure
	subscriptionID := azure.GetSubscriptionIDFromEnvVar(t)
	exists := azure.WafPolicyExists(t, wafPolicyName, resourceGroupName, subscriptionID)
	assert.True(t, exists, "WAF policy should exist in Azure")

	// Get the WAF policy details
	wafPolicy := azure.GetWafPolicy(t, wafPolicyName, resourceGroupName, subscriptionID)
	assert.NotNil(t, wafPolicy, "WAF policy should not be nil")

	// Verify policy settings
	if wafPolicy.PolicySettings != nil {
		policySettings := wafPolicy.PolicySettings
		assert.NotNil(t, policySettings.Enabled, "Policy should be enabled")
		assert.True(t, *policySettings.Enabled, "Policy should be enabled")

		if policySettings.Mode != nil {
			assert.Equal(t, "Prevention", *policySettings.Mode, "Policy mode should be Prevention")
		}

		if policySettings.RequestBodyCheck != nil {
			assert.True(t, *policySettings.RequestBodyCheck, "Request body check should be enabled")
		}

		if policySettings.MaxRequestBodySizeInKb != nil {
			assert.Equal(t, int32(128), *policySettings.MaxRequestBodySizeInKb, "Max request body size should be 128KB")
		}

		if policySettings.FileUploadLimitInMb != nil {
			assert.Equal(t, int32(100), *policySettings.FileUploadLimitInMb, "File upload limit should be 100MB")
		}
	}
}

// Helper function to validate WAF policy ID format
func validateWafPolicyID(t *testing.T, wafPolicyID string) {
	require.NotEmpty(t, wafPolicyID, "WAF policy ID should not be empty")

	// WAF policy ID should follow the format: /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/{policy-name}
	expectedPrefix := "/subscriptions/"
	assert.True(t, strings.HasPrefix(wafPolicyID, expectedPrefix), "WAF policy ID should start with /subscriptions/")

	expectedSuffix := "/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/"
	assert.True(t, strings.Contains(wafPolicyID, expectedSuffix), "WAF policy ID should contain the correct provider path")
}

// Test to validate WAF policy ID format
func TestWafPolicyIDFormat(t *testing.T) {
	t.Parallel()

	// Generate a random name for the resource group
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("terratest-waf-rg-%s", uniqueID)
	wafPolicyName := fmt.Sprintf("terratest-waf-policy-%s", uniqueID)

	// Configure Terraform options
	terraformOptions := &terraform.Options{
		// Path to the Terraform code
		TerraformDir: "../test/fixtures/basic",

		// Variables to pass to Terraform
		Vars: map[string]interface{}{
			"name_prefix":         "terratest",
			"resource_group_name": resourceGroupName,
			"location":            "East US",
			"waf_policy_name":     wafPolicyName,
		},

		// Retry up to 3 times on known errors
		MaxRetries:         3,
		TimeBetweenRetries: "5s",
		RetryableTerraformErrors: map[string]string{
			"ResourceInUse": "Resource is in use by another resource",
		},
	}

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Get the outputs
	wafPolicyID := terraform.Output(t, terraformOptions, "waf_policy_id")

	// Validate the WAF policy ID format
	validateWafPolicyID(t, wafPolicyID)
}
