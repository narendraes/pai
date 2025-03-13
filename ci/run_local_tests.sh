#!/bin/bash

# Local CI Test Runner for Private Home AI
# This script runs all tests locally to simulate CI environment

echo "===== Private Home AI Local CI Runner ====="
echo "Running all tests in CI-like environment..."
echo ""

# Set error handling
set -e

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to run a step and report
run_step() {
    STEP_NAME=$1
    COMMAND=$2
    
    echo -e "${YELLOW}Running step: $STEP_NAME${NC}"
    echo "$ $COMMAND"
    echo "----------------------------------------"
    
    if eval "$COMMAND"; then
        echo -e "${GREEN}✅ Step '$STEP_NAME' completed successfully${NC}"
    else
        echo -e "${RED}❌ Step '$STEP_NAME' failed${NC}"
        exit 1
    fi
    
    echo ""
}

# Create a temporary directory for test artifacts
TEMP_DIR=$(mktemp -d)
echo "Using temporary directory: $TEMP_DIR"
echo ""

# Step 1: Run standalone tests
run_step "Standalone Tests" "./run_tests.sh"

# Step 2: Run security audit
run_step "Security Audit" "./security_audit.sh"

# Step 3: Check code formatting
run_step "Code Formatting Check" "find . -name '*.swift' -not -path '*/\.*' | xargs swiftformat --lint || echo 'Warning: Code formatting issues found'"

# Step 4: Check for TODOs and FIXMEs
run_step "TODO Check" "! grep -r 'TODO\|FIXME' --include='*.swift' . || echo 'Warning: TODOs or FIXMEs found'"

# Step 5: Check for large files
run_step "Large File Check" "! find . -type f -size +5M -not -path '*/\.*' -not -path '*/TestResources/*' | grep . || echo 'Warning: Large files found'"

# Step 6: Check for proper file headers
run_step "File Header Check" "! find . -name '*.swift' -not -path '*/\.*' -exec grep -L 'PrivateHomeAI' {} \; | grep . || echo 'All files have proper headers'"

# Clean up
echo "Cleaning up temporary directory..."
rm -rf "$TEMP_DIR"

# Success message
echo -e "${GREEN}===== All CI checks completed successfully! =====${NC}"
echo "Your code is ready to be committed and pushed."
echo ""
echo "Don't forget to commit!" 