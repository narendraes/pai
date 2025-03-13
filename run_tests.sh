#!/bin/bash

# Run Tests Script for Private Home AI
# This script runs all the standalone tests for the core components

echo "===== Private Home AI Test Runner ====="
echo "Running all standalone tests..."
echo ""

# Function to run a test and report results
run_test() {
    TEST_NAME=$1
    TEST_FILE=$2
    
    echo "🧪 Running $TEST_NAME tests..."
    swift "$TEST_FILE"
    
    if [ $? -eq 0 ]; then
        echo "✅ $TEST_NAME tests completed successfully"
    else
        echo "❌ $TEST_NAME tests failed"
        FAILED_TESTS="$FAILED_TESTS $TEST_NAME"
    fi
    echo "----------------------------------------"
    echo ""
}

# Initialize variables
FAILED_TESTS=""

# Run all tests
run_test "SecurityError" "TestSecurityError.swift"
run_test "JailbreakDetection" "TestJailbreakDetectionService.swift"
run_test "Encryption" "TestEncryptionService.swift"
run_test "Keychain" "TestKeychainService.swift"

# Report summary
echo "===== Test Summary ====="
if [ -z "$FAILED_TESTS" ]; then
    echo "🎉 All tests passed successfully!"
else
    echo "❌ The following tests failed: $FAILED_TESTS"
    exit 1
fi

echo ""
echo "To run individual tests, use:"
echo "swift TestSecurityError.swift"
echo "swift TestJailbreakDetectionService.swift"
echo "swift TestEncryptionService.swift"
echo "swift TestKeychainService.swift" 