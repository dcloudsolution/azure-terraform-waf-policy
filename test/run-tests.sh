#!/bin/bash

# Azure WAF Policy Module - Test Runner Script
# This script provides an easy way to run Terratest for the Azure WAF Policy module

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists go; then
        print_error "Go is not installed. Please install Go 1.21 or later."
        exit 1
    fi
    
    if ! command_exists az; then
        print_error "Azure CLI is not installed. Please install Azure CLI."
        exit 1
    fi
    
    if ! command_exists terraform; then
        print_error "Terraform is not installed. Please install Terraform."
        exit 1
    fi
    
    print_success "All prerequisites are installed."
}

# Function to check Azure authentication
check_azure_auth() {
    print_status "Checking Azure authentication..."
    
    if ! az account show >/dev/null 2>&1; then
        print_error "Azure CLI is not authenticated. Please run 'az login' first."
        exit 1
    fi
    
    local subscription_id=$(az account show --query id -o tsv)
    print_success "Authenticated with Azure subscription: $subscription_id"
}

# Function to setup Go dependencies
setup_dependencies() {
    print_status "Setting up Go dependencies..."
    
    if [ ! -f "go.mod" ]; then
        print_error "go.mod not found. Please run this script from the test directory."
        exit 1
    fi
    
    go mod tidy
    go mod download
    
    print_success "Go dependencies are ready."
}

# Function to run tests
run_tests() {
    local test_name="$1"
    local timeout="${2:-30m}"
    
    print_status "Running tests..."
    
    if [ -n "$test_name" ]; then
        print_status "Running specific test: $test_name"
        go test -v -run "$test_name" -timeout "$timeout"
    else
        print_status "Running all tests"
        go test -v -timeout "$timeout" -parallel 4
    fi
    
    if [ $? -eq 0 ]; then
        print_success "Tests completed successfully!"
    else
        print_error "Tests failed!"
        exit 1
    fi
}

# Function to cleanup resources
cleanup_resources() {
    print_status "Cleaning up any leftover test resources..."
    
    # List and delete resource groups created by tests
    local resource_groups=$(az group list --query "[?contains(name, 'terratest-waf-rg-')].name" -o tsv 2>/dev/null || true)
    
    if [ -n "$resource_groups" ]; then
        print_warning "Found leftover test resource groups. Cleaning up..."
        echo "$resource_groups" | while read -r rg; do
            if [ -n "$rg" ]; then
                print_status "Deleting resource group: $rg"
                az group delete --name "$rg" --yes --no-wait 2>/dev/null || true
            fi
        done
        print_success "Cleanup initiated."
    else
        print_success "No leftover resources found."
    fi
}

# Function to show help
show_help() {
    echo "Azure WAF Policy Module - Test Runner"
    echo ""
    echo "Usage: $0 [OPTIONS] [TEST_NAME]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -c, --cleanup       Clean up leftover test resources"
    echo "  -t, --timeout TIME  Set test timeout (default: 30m)"
    echo "  -s, --setup-only    Only setup dependencies, don't run tests"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Run all tests"
    echo "  $0 TestWafPolicyBasic                # Run specific test"
    echo "  $0 -t 60m                            # Run all tests with 60 minute timeout"
    echo "  $0 -c                                # Clean up leftover resources"
    echo "  $0 -s                                # Setup dependencies only"
    echo ""
    echo "Available tests:"
    echo "  TestWafPolicyBasic"
    echo "  TestWafPolicyWithCustomRules"
    echo "  TestWafPolicyWithManagedRules"
    echo "  TestWafPolicyTags"
    echo "  TestWafPolicyPolicySettings"
    echo "  TestWafPolicyIDFormat"
}

# Main function
main() {
    local test_name=""
    local timeout="30m"
    local cleanup_only=false
    local setup_only=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--cleanup)
                cleanup_only=true
                shift
                ;;
            -t|--timeout)
                timeout="$2"
                shift 2
                ;;
            -s|--setup-only)
                setup_only=true
                shift
                ;;
            -*)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                test_name="$1"
                shift
                ;;
        esac
    done
    
    # Change to script directory
    cd "$(dirname "$0")"
    
    # Run cleanup if requested
    if [ "$cleanup_only" = true ]; then
        check_prerequisites
        check_azure_auth
        cleanup_resources
        exit 0
    fi
    
    # Setup only if requested
    if [ "$setup_only" = true ]; then
        check_prerequisites
        check_azure_auth
        setup_dependencies
        exit 0
    fi
    
    # Run full test suite
    check_prerequisites
    check_azure_auth
    setup_dependencies
    run_tests "$test_name" "$timeout"
    
    # Cleanup on success
    cleanup_resources
}

# Run main function with all arguments
main "$@"
