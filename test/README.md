# Azure WAF Policy Module - Terratest

This directory contains comprehensive tests for the Azure WAF Policy Terraform module using [Terratest](https://terratest.gruntwork.io/).

## Overview

Terratest is a Go library that makes it easier to write automated tests for your infrastructure code. It provides a collection of helper functions and patterns for common infrastructure testing tasks.

## Test Structure

```
test/
├── fixtures/                    # Test fixtures (Terraform configurations)
│   ├── basic/                   # Basic WAF policy test
│   ├── custom-rules/            # WAF policy with custom rules
│   ├── managed-rules/           # WAF policy with managed rules and overrides
│   └── policy-settings/         # WAF policy with custom policy settings
├── waf_policy_test.go          # Main test file
├── go.mod                      # Go module dependencies
└── README.md                   # This file
```

## Test Cases

### 1. Basic WAF Policy Test (`TestWafPolicyBasic`)
- Tests basic WAF policy creation with default settings
- Verifies resource creation and basic properties
- Validates resource group and location settings

### 2. Custom Rules Test (`TestWafPolicyWithCustomRules`)
- Tests WAF policy with custom rules
- Validates custom rule configuration
- Checks rule priorities and match conditions

### 3. Managed Rules Test (`TestWafPolicyWithManagedRules`)
- Tests WAF policy with managed rule sets (OWASP)
- Validates rule group overrides
- Checks rule enablement and actions

### 4. Tags Test (`TestWafPolicyTags`)
- Tests WAF policy with custom tags
- Validates tag assignment and retrieval
- Ensures proper tag formatting

### 5. Policy Settings Test (`TestWafPolicyPolicySettings`)
- Tests WAF policy with custom policy settings
- Validates mode, request body checks, and limits
- Tests log scrubbing configuration

### 6. ID Format Test (`TestWafPolicyIDFormat`)
- Validates WAF policy ID format
- Ensures proper Azure resource ID structure

## Prerequisites

### 1. Go Installation
Install Go 1.21 or later:
```bash
# macOS
brew install go

# Ubuntu/Debian
sudo apt update
sudo apt install golang-go

# Windows
# Download from https://golang.org/dl/
```

### 2. Azure CLI Authentication
Authenticate with Azure:
```bash
az login
az account set --subscription "your-subscription-id"
```

### 3. Environment Variables
Set the following environment variables:
```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_TENANT_ID="your-tenant-id"
```

Or use Azure CLI authentication (recommended for local testing):
```bash
export ARM_USE_CLI=true
```

## Running Tests

### Run All Tests
```bash
cd test
go test -v
```

### Run Specific Test
```bash
cd test
go test -v -run TestWafPolicyBasic
```

### Run Tests with Timeout
```bash
cd test
go test -v -timeout 30m
```

### Run Tests in Parallel
```bash
cd test
go test -v -parallel 4
```

## Test Configuration

### Test Timeouts
- Default test timeout: 20 minutes
- Individual test timeout: 30 minutes
- Terraform operations timeout: 10 minutes

### Retry Configuration
- Max retries: 3
- Time between retries: 5 seconds
- Retryable errors: ResourceInUse

### Resource Naming
- Resource groups: `terratest-waf-rg-{unique-id}`
- WAF policies: `terratest-waf-policy-{unique-id}`
- All resources include test tags

## Test Fixtures

### Basic Fixture
Tests the minimal WAF policy configuration with:
- Default managed rules (OWASP 3.2)
- Basic resource group and location
- Standard tags

### Custom Rules Fixture
Tests WAF policy with custom rules:
- IP-based blocking rules
- User-Agent based allow rules
- Multiple match conditions

### Managed Rules Fixture
Tests WAF policy with managed rules:
- OWASP rule set with overrides
- Rule group modifications
- Individual rule enablement/disablement

### Policy Settings Fixture
Tests WAF policy with custom settings:
- Prevention mode
- Request body inspection
- File upload limits
- Log scrubbing configuration

## Best Practices

### 1. Resource Cleanup
All tests include proper cleanup using `defer terraform.Destroy()` to ensure resources are removed after testing.

### 2. Parallel Execution
Tests are designed to run in parallel using `t.Parallel()` for faster execution.

### 3. Unique Naming
Each test uses unique resource names to avoid conflicts when running tests in parallel.

### 4. Comprehensive Validation
Tests validate both Terraform outputs and actual Azure resource properties.

### 5. Error Handling
Tests include proper error handling and retry logic for transient failures.

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Ensure Azure CLI is authenticated: `az login`
   - Check environment variables are set correctly
   - Verify subscription ID is correct

2. **Resource Conflicts**
   - Tests use unique IDs to avoid conflicts
   - If conflicts occur, check for leftover resources from previous test runs

3. **Timeout Issues**
   - Increase test timeout if needed: `-timeout 60m`
   - Check Azure service availability
   - Verify network connectivity

4. **Go Module Issues**
   - Run `go mod tidy` to clean up dependencies
   - Ensure Go version is 1.21 or later

### Debug Mode
Run tests with verbose output:
```bash
go test -v -timeout 30m
```

### Clean Up Resources
If tests fail and leave resources behind:
```bash
# List resource groups
az group list --query "[?contains(name, 'terratest-waf-rg-')].name" -o table

# Delete specific resource group
az group delete --name "terratest-waf-rg-{id}" --yes --no-wait
```

## Contributing

When adding new tests:

1. Create a new test fixture in the `fixtures/` directory
2. Add corresponding test function in `waf_policy_test.go`
3. Follow existing naming conventions
4. Include proper cleanup and error handling
5. Update this README with test description

## Dependencies

- [Terratest](https://github.com/gruntwork-io/terratest) - Infrastructure testing framework
- [Testify](https://github.com/stretchr/testify) - Testing toolkit
- [Azure SDK for Go](https://github.com/Azure/azure-sdk-for-go) - Azure resource management

## License

This testing suite follows the same license as the main module.
