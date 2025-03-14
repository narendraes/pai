# Private Home AI

A privacy-focused iOS application for home automation and security, powered by local AI.

## Features

- **Local Processing**: All AI processing happens on-device for maximum privacy
- **Camera Integration**: Monitor and analyze camera feeds
- **Secure Authentication**: Biometric and password authentication
- **Encrypted Storage**: All data is encrypted at rest
- **Jailbreak Detection**: Enhanced security with jailbreak detection
- **Chat Interface**: Natural language interaction with your home system

## Architecture

The app is built using a modular architecture with the following components:

### Core Modules

- **Security**: Encryption, authentication, and jailbreak detection
- **Storage**: Secure local data persistence
- **Network**: SSH connectivity and LLM integration
- **UI**: SwiftUI-based user interface

### Security Features

- End-to-end encryption using AES-GCM
- Secure credential storage in Keychain
- Biometric authentication (Face ID/Touch ID)
- Jailbreak detection to prevent unauthorized access

## Getting Started

### Requirements

- iOS 15.0+ / macOS 12.0+
- Xcode 14.0+
- Swift 5.7+

### Installation

1. Clone the repository
2. Open the project in Xcode
3. Install dependencies using Swift Package Manager
4. Build and run the app

## Usage

1. Launch the app and authenticate using biometrics or password
2. Connect to your home server
3. Use the chat interface to interact with your home system
4. Monitor cameras and analyze footage
5. Adjust settings as needed

## Privacy

This app is designed with privacy as a core principle:

- No data is sent to external servers without explicit permission
- All processing happens locally on your device
- Data is encrypted at rest and in transit
- No analytics or tracking

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift) for encryption functionality
- [Ollama](https://ollama.ai) for local LLM capabilities 