# Makefile for Azure WAF Policy Module Tests

.PHONY: help test test-basic test-custom-rules test-managed-rules test-policy-settings test-tags test-id-format test-all clean setup

# Default target
help:
	@echo "Available targets:"
	@echo "  setup              - Install Go dependencies"
	@echo "  test               - Run all tests"
	@echo "  test-basic         - Run basic WAF policy test"
	@echo "  test-custom-rules  - Run custom rules test"
	@echo "  test-managed-rules - Run managed rules test"
	@echo "  test-policy-settings - Run policy settings test"
	@echo "  test-tags          - Run tags test"
	@echo "  test-id-format     - Run ID format test"
	@echo "  test-all           - Run all tests with verbose output"
	@echo "  clean              - Clean up test artifacts"
	@echo "  lint               - Run Go linting"

# Install Go dependencies
setup:
	@echo "Installing Go dependencies..."
	go mod tidy
	go mod download

# Run all tests
test:
	@echo "Running all tests..."
	go test -v -timeout 30m

# Run specific tests
test-basic:
	@echo "Running basic WAF policy test..."
	go test -v -run TestWafPolicyBasic -timeout 20m

test-custom-rules:
	@echo "Running custom rules test..."
	go test -v -run TestWafPolicyWithCustomRules -timeout 20m

test-managed-rules:
	@echo "Running managed rules test..."
	go test -v -run TestWafPolicyWithManagedRules -timeout 20m

test-policy-settings:
	@echo "Running policy settings test..."
	go test -v -run TestWafPolicyPolicySettings -timeout 20m

test-tags:
	@echo "Running tags test..."
	go test -v -run TestWafPolicyTags -timeout 20m

test-id-format:
	@echo "Running ID format test..."
	go test -v -run TestWafPolicyIDFormat -timeout 20m

# Run all tests with verbose output and longer timeout
test-all:
	@echo "Running all tests with verbose output..."
	go test -v -timeout 60m -parallel 4

# Clean up test artifacts
clean:
	@echo "Cleaning up test artifacts..."
	find . -name "*.tfstate*" -delete
	find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name ".terraform.lock.hcl" -delete

# Run Go linting
lint:
	@echo "Running Go linting..."
	golangci-lint run

# Check if required tools are installed
check-tools:
	@echo "Checking required tools..."
	@command -v go >/dev/null 2>&1 || { echo "Go is required but not installed. Aborting." >&2; exit 1; }
	@command -v az >/dev/null 2>&1 || { echo "Azure CLI is required but not installed. Aborting." >&2; exit 1; }
	@echo "All required tools are installed."

# Validate Azure authentication
check-auth:
	@echo "Checking Azure authentication..."
	@az account show >/dev/null 2>&1 || { echo "Azure CLI not authenticated. Run 'az login' first." >&2; exit 1; }
	@echo "Azure authentication is valid."

# Run tests with pre-checks
test-safe: check-tools check-auth setup test

# Run tests in CI environment
test-ci:
	@echo "Running tests in CI environment..."
	go test -v -timeout 30m -parallel 2

# Format Go code
fmt:
	@echo "Formatting Go code..."
	go fmt ./...

# Run tests with coverage
test-coverage:
	@echo "Running tests with coverage..."
	go test -v -timeout 30m -coverprofile=coverage.out
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# Run tests for specific fixture
test-fixture:
	@echo "Running tests for fixture: $(FIXTURE)"
	@if [ -z "$(FIXTURE)" ]; then echo "Usage: make test-fixture FIXTURE=basic"; exit 1; fi
	go test -v -run TestWafPolicy -timeout 20m -args -fixture=$(FIXTURE)
