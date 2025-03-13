# Private Home AI Manual Testing Guide

## Overview
This document outlines the manual testing procedures for the Private Home AI application. These tests should be performed regularly during development and before each release to ensure all components function correctly.

## Prerequisites
- iOS device running iOS 15.0 or later
- Mac with Ollama installed and running on localhost:11434
- SSH server configured on the Mac
- Test camera setup (Mac webcam, Ring or Blink cameras if available)
- Test user credentials

## 1. Security Component Tests

### 1.1 Jailbreak Detection
1. Run the app on a non-jailbroken device
   - Expected: App should launch normally
2. Run the app on a jailbroken device or simulator with jailbreak files
   - Expected: App should detect jailbreak and show appropriate warning

### 1.2 Encryption Service
1. Test data encryption/decryption
   - Navigate to Settings > Security > Encryption Test
   - Enter test data and encryption key
   - Encrypt the data and then decrypt it
   - Expected: Decrypted data should match original input

2. Test password hashing
   - Navigate to Settings > Security > Password Test
   - Enter test password and salt
   - Generate hash
   - Expected: Hash should be consistent for same inputs

### 1.3 Keychain Service
1. Test credential storage
   - Navigate to Login screen
   - Enter test credentials and login
   - Close app completely and relaunch
   - Expected: Credentials should be securely stored and retrieved

2. Test credential deletion
   - Navigate to Settings > Security > Clear Credentials
   - Confirm deletion
   - Expected: All stored credentials should be removed

## 2. Network Component Tests

### 2.1 SSH Connection
1. Test connection establishment
   - Navigate to Connection screen
   - Enter valid SSH credentials for Mac
   - Initiate connection
   - Expected: Connection should establish successfully with status indicator

2. Test connection failure handling
   - Enter invalid SSH credentials
   - Attempt connection
   - Expected: Appropriate error message should display

3. Test connection persistence
   - Establish connection
   - Put app in background for 5 minutes
   - Return to app
   - Expected: Connection should remain active or reconnect automatically

### 2.2 Ollama Service
1. Test model listing
   - Navigate to AI > Models
   - Expected: List of available models from Ollama should display

2. Test model pulling
   - Select a model not yet downloaded
   - Initiate pull
   - Expected: Download progress should display and complete successfully

3. Test completion generation
   - Navigate to Chat screen
   - Enter a test prompt
   - Submit for completion
   - Expected: Response should be generated and displayed

## 3. UI Component Tests

### 3.1 Authentication View
1. Test login form validation
   - Enter invalid formats for username/password
   - Expected: Validation errors should display

2. Test login process
   - Enter valid credentials
   - Expected: Login should succeed and navigate to main interface

3. Test biometric authentication (if implemented)
   - Enable biometric login in settings
   - Log out and attempt biometric login
   - Expected: Should authenticate without manual credential entry

### 3.2 Chat Interface
1. Test message sending
   - Enter various message types (text, code, long content)
   - Expected: All messages should send and display correctly

2. Test message history
   - Send multiple messages
   - Close app and relaunch
   - Expected: Message history should persist

3. Test media attachments
   - Attach images to messages
   - Expected: Images should upload and display correctly

### 3.3 Camera Interface
1. Test camera listing
   - Navigate to Cameras screen
   - Expected: All configured cameras should be listed

2. Test live feed
   - Select a camera
   - Expected: Live feed should load with minimal latency

3. Test recording controls
   - Initiate recording
   - Stop recording after 30 seconds
   - Expected: Recording should save successfully

## 4. Integration Tests

### 4.1 End-to-End Workflow
1. Test complete workflow
   - Login to app
   - Connect to Mac
   - View camera feed
   - Send chat message about camera feed
   - Receive AI response
   - Expected: All components should work together seamlessly

### 4.2 Error Recovery
1. Test network interruption
   - Establish connection
   - Disable network connectivity
   - Re-enable network
   - Expected: App should detect disconnection and reconnect automatically

2. Test service unavailability
   - Stop Ollama service on Mac
   - Attempt AI interaction
   - Expected: Appropriate error message should display
   - Restart Ollama service
   - Expected: Functionality should resume

## 5. Performance Tests

### 5.1 Response Times
1. Measure chat response time
   - Send a standard test prompt
   - Measure time until response begins
   - Expected: Response should begin within 2 seconds

2. Measure camera feed latency
   - Start camera feed
   - Perform a timed action in front of camera
   - Measure delay until action appears in feed
   - Expected: Latency should be under 1 second

### 5.2 Resource Usage
1. Monitor memory usage
   - Use app for 10 minutes with various features
   - Check memory usage in iOS settings
   - Expected: Memory usage should remain under 200MB

2. Monitor battery impact
   - Note battery percentage
   - Use app continuously for 1 hour
   - Note battery percentage again
   - Expected: Battery usage should be less than 10% per hour

## 6. Accessibility Tests

### 6.1 VoiceOver Compatibility
1. Enable VoiceOver
   - Navigate through all main screens
   - Expected: All elements should be properly labeled and navigable

### 6.2 Dynamic Type
1. Increase text size in iOS settings
   - Navigate through app
   - Expected: All text should resize appropriately without layout issues

## 7. Security Audit Tests

### 7.1 Data Storage
1. Check for sensitive data in app files
   - Use iOS file browser to examine app storage
   - Expected: No plaintext credentials or sensitive data should be visible

### 7.2 Network Traffic
1. Monitor network traffic
   - Use a proxy tool to monitor app traffic
   - Expected: All traffic should be encrypted

## Test Reporting

### Issue Template
When reporting issues found during manual testing, use the following format:

```
Issue: [Brief description]
Steps to reproduce:
1. 
2.
3.

Expected behavior:
Actual behavior:
Device/OS version:
App version:
Screenshots/recordings:
```

### Test Completion Checklist
- [ ] All security tests passed
- [ ] All network tests passed
- [ ] All UI tests passed
- [ ] All integration tests passed
- [ ] All performance tests passed
- [ ] All accessibility tests passed
- [ ] All security audit tests passed

## Regression Testing
Before each release, perform the following regression tests:
1. Run all critical path tests
2. Verify fixed bugs remain fixed
3. Check compatibility with latest iOS version
4. Verify performance metrics remain within acceptable ranges 