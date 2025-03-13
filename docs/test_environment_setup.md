# Test Environment Setup Guide

This guide provides instructions for setting up a proper test environment for the Private Home AI application.

## Local Development Environment

### Prerequisites
- macOS 12.0 or later
- Xcode 13.0 or later
- Swift 5.5 or later
- iOS 15.0 simulator or physical device
- Git

### Setup Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/privatehomeai.git
   cd privatehomeai
   ```

2. **Install Dependencies**
   The project uses Swift Package Manager for dependencies. Open the project in Xcode and wait for dependencies to resolve automatically.

3. **Configure Ollama**
   - Download and install Ollama from [https://ollama.ai/](https://ollama.ai/)
   - Start the Ollama service:
     ```bash
     ollama serve
     ```
   - Pull a test model:
     ```bash
     ollama pull llama2
     ```
   - Verify Ollama is running at http://localhost:11434

4. **Configure SSH Server**
   - Enable Remote Login in System Preferences > Sharing
   - Create a test user account with limited permissions
   - Set up SSH key authentication for testing

5. **Camera Setup**
   - Ensure your Mac's webcam is functional
   - For Ring/Blink camera testing, set up test accounts with demo cameras

## Running Tests

### Standalone Tests
We've created standalone test files that can be run directly with Swift:

1. **Run All Tests**
   ```bash
   ./run_tests.sh
   ```

2. **Run Individual Tests**
   ```bash
   swift TestSecurityError.swift
   swift TestJailbreakDetectionService.swift
   swift TestEncryptionService.swift
   swift TestKeychainService.swift
   ```

### Manual Testing
For manual testing, follow the procedures in the [Manual Testing Guide](manual_testing.md).

## Test Data

### Test Credentials
Use these credentials for testing purposes only:
- Username: `testuser`
- Password: `Test@1234`
- SSH Host: `localhost`
- SSH Port: `22`

### Test Files
Sample test files are available in the `TestResources` directory:
- `test_image.jpg`: Standard test image
- `test_video.mp4`: Sample video clip
- `large_file.bin`: Large binary file for performance testing

## Monitoring Tools

### Network Monitoring
- Use Charles Proxy or Wireshark to monitor network traffic
- Configure with the provided SSL certificates for HTTPS inspection

### Performance Monitoring
- Use Xcode Instruments for performance profiling
- Enable the Memory Graph and Time Profiler instruments

### Security Testing
- Use the provided `security_audit.sh` script for basic security checks
- For advanced testing, use tools like MobSF (Mobile Security Framework)

## Continuous Integration

### GitHub Actions
The repository includes GitHub Actions workflows for automated testing:
- `unit_tests.yml`: Runs unit tests on each PR
- `ui_tests.yml`: Runs UI tests on each PR to main
- `security_scan.yml`: Performs security scans weekly

### Local CI Testing
To run CI tests locally before pushing:
```bash
./ci/run_local_tests.sh
```

## Troubleshooting

### Common Issues
1. **SSH Connection Failures**
   - Verify SSH service is running: `sudo systemsetup -getremotelogin`
   - Check firewall settings: `sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate`

2. **Ollama Service Issues**
   - Restart Ollama: `ollama serve`
   - Check logs: `cat ~/.ollama/logs/ollama.log`

3. **Test Failures**
   - Check for environment-specific issues
   - Verify test dependencies are installed
   - Check for permission issues

### Getting Help
If you encounter persistent issues:
1. Check the project wiki for known issues
2. File an issue on GitHub with detailed reproduction steps
3. Contact the development team on Slack 