#!/bin/bash

# Security Audit Script for Private Home AI
# This script performs basic security checks on the codebase

echo "===== Private Home AI Security Audit ====="
echo "Running security checks..."
echo ""

# Initialize counters
ISSUES_FOUND=0
WARNINGS=0

# Colors for output
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to check for hardcoded secrets
check_hardcoded_secrets() {
    echo "🔍 Checking for hardcoded secrets..."
    
    # Patterns to search for
    PATTERNS=(
        "password"
        "apikey"
        "api_key"
        "secret"
        "token"
        "auth"
        "credential"
        "BEGIN PRIVATE KEY"
        "BEGIN RSA PRIVATE KEY"
    )
    
    # Files to exclude
    EXCLUDE_DIRS=(
        ".git"
        ".build"
        "TestResources"
        "Tests"
    )
    
    EXCLUDE_PATTERN=$(printf " --exclude-dir=%s" "${EXCLUDE_DIRS[@]}")
    
    SECRET_COUNT=0
    
    for pattern in "${PATTERNS[@]}"; do
        echo "  Searching for '$pattern'..."
        RESULTS=$(grep -r -i -l $EXCLUDE_PATTERN "$pattern" --include="*.swift" --include="*.json" --include="*.plist" .)
        
        if [ -n "$RESULTS" ]; then
            echo -e "${YELLOW}  ⚠️ Potential secrets found with pattern '$pattern':${NC}"
            echo "$RESULTS" | while read -r file; do
                echo "    - $file"
                SECRET_COUNT=$((SECRET_COUNT + 1))
            done
        fi
    done
    
    if [ $SECRET_COUNT -eq 0 ]; then
        echo -e "${GREEN}  ✅ No hardcoded secrets found${NC}"
    else
        echo -e "${YELLOW}  ⚠️ Found $SECRET_COUNT potential secrets${NC}"
        WARNINGS=$((WARNINGS + SECRET_COUNT))
    fi
    
    echo ""
}

# Function to check for insecure API endpoints
check_insecure_endpoints() {
    echo "🔍 Checking for insecure API endpoints..."
    
    HTTP_COUNT=$(grep -r -l "http://" --include="*.swift" . | wc -l)
    
    if [ $HTTP_COUNT -eq 0 ]; then
        echo -e "${GREEN}  ✅ No insecure HTTP endpoints found${NC}"
    else
        echo -e "${RED}  ❌ Found $HTTP_COUNT insecure HTTP endpoints${NC}"
        grep -r -l "http://" --include="*.swift" . | while read -r file; do
            echo "    - $file"
        done
        ISSUES_FOUND=$((ISSUES_FOUND + HTTP_COUNT))
    fi
    
    echo ""
}

# Function to check for proper encryption usage
check_encryption() {
    echo "🔍 Checking encryption implementation..."
    
    # Check for weak encryption algorithms
    WEAK_CRYPTO=$(grep -r -l -E "MD5|RC4|DES|ECB" --include="*.swift" .)
    
    if [ -n "$WEAK_CRYPTO" ]; then
        echo -e "${RED}  ❌ Weak cryptographic algorithms found:${NC}"
        echo "$WEAK_CRYPTO" | while read -r file; do
            echo "    - $file"
        done
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    else
        echo -e "${GREEN}  ✅ No weak cryptographic algorithms found${NC}"
    fi
    
    # Check for proper keychain usage
    KEYCHAIN_USAGE=$(grep -r -l "kSecAttrAccessible" --include="*.swift" .)
    
    if [ -z "$KEYCHAIN_USAGE" ]; then
        echo -e "${YELLOW}  ⚠️ No keychain accessibility settings found${NC}"
        WARNINGS=$((WARNINGS + 1))
    else
        INSECURE_KEYCHAIN=$(grep -r -l "kSecAttrAccessibleAlways" --include="*.swift" .)
        if [ -n "$INSECURE_KEYCHAIN" ]; then
            echo -e "${RED}  ❌ Insecure keychain accessibility found:${NC}"
            echo "$INSECURE_KEYCHAIN" | while read -r file; do
                echo "    - $file"
            done
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        else
            echo -e "${GREEN}  ✅ Proper keychain accessibility settings found${NC}"
        fi
    fi
    
    echo ""
}

# Function to check for jailbreak detection
check_jailbreak_detection() {
    echo "🔍 Checking jailbreak detection..."
    
    JAILBREAK_FILES=$(find . -name "*Jailbreak*.swift" -o -name "*jailbreak*.swift")
    
    if [ -z "$JAILBREAK_FILES" ]; then
        echo -e "${YELLOW}  ⚠️ No jailbreak detection files found${NC}"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}  ✅ Jailbreak detection files found:${NC}"
        echo "$JAILBREAK_FILES" | while read -r file; do
            echo "    - $file"
        done
        
        # Check for common jailbreak detection methods
        DETECTION_METHODS=0
        
        if grep -q "fileExists" "$JAILBREAK_FILES"; then
            DETECTION_METHODS=$((DETECTION_METHODS + 1))
            echo -e "${GREEN}  ✅ File existence checks found${NC}"
        fi
        
        if grep -q "canOpenURL" "$JAILBREAK_FILES"; then
            DETECTION_METHODS=$((DETECTION_METHODS + 1))
            echo -e "${GREEN}  ✅ URL scheme checks found${NC}"
        fi
        
        if grep -q "write" "$JAILBREAK_FILES" && grep -q "private" "$JAILBREAK_FILES"; then
            DETECTION_METHODS=$((DETECTION_METHODS + 1))
            echo -e "${GREEN}  ✅ Sandbox escape checks found${NC}"
        fi
        
        if [ $DETECTION_METHODS -lt 2 ]; then
            echo -e "${YELLOW}  ⚠️ Limited jailbreak detection methods found${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
    
    echo ""
}

# Function to check for proper certificate pinning
check_certificate_pinning() {
    echo "🔍 Checking certificate pinning..."
    
    PINNING_FILES=$(grep -r -l -E "certificatePinning|serverTrust|SSLPinning" --include="*.swift" .)
    
    if [ -z "$PINNING_FILES" ]; then
        echo -e "${RED}  ❌ No certificate pinning implementation found${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    else
        echo -e "${GREEN}  ✅ Certificate pinning implementation found:${NC}"
        echo "$PINNING_FILES" | while read -r file; do
            echo "    - $file"
        done
    fi
    
    echo ""
}

# Run all checks
check_hardcoded_secrets
check_insecure_endpoints
check_encryption
check_jailbreak_detection
check_certificate_pinning

# Print summary
echo "===== Security Audit Summary ====="
if [ $ISSUES_FOUND -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 No security issues or warnings found!${NC}"
elif [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${YELLOW}⚠️ No critical security issues found, but $WARNINGS warnings to address${NC}"
else
    echo -e "${RED}❌ Found $ISSUES_FOUND security issues and $WARNINGS warnings${NC}"
fi

echo ""
echo "For a more comprehensive security audit, consider using specialized tools like:"
echo "- MobSF (Mobile Security Framework)"
echo "- Xcode's Address Sanitizer"
echo "- SwiftLint with security rules"
echo "- Dependency vulnerability scanners"

exit $ISSUES_FOUND 