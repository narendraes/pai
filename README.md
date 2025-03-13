# Private Home AI

A secure, private AI assistant for your home that connects to your Mac and leverages local LLMs through Ollama.

## Features

- **Secure Authentication**: SSH-based secure connection to your Mac
- **Local AI Processing**: Integration with Ollama for local LLM inference
- **Chat Interface**: Interact with AI models through a clean chat interface
- **Device Management**: Monitor and manage connected devices
- **Security First**: Jailbreak detection, encryption, and secure credential storage
- **Privacy Focused**: All data stays local, no cloud dependencies

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- Mac with Ollama installed (for LLM functionality)

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern and is organized into the following components:

### Core

- **Network**: Handles API communication and SSH connections
- **Security**: Manages encryption, keychain access, and jailbreak detection
- **Utils**: Contains utility classes and dependency management

### Features

- **Authentication**: Handles user login and session management
- **Chat**: Provides the chat interface for interacting with LLMs
- **Devices**: Manages connected device discovery and monitoring
- **Home**: Dashboard showing system status and metrics
- **Settings**: User preferences and app configuration

## Security Features

- **SSH Tunneling**: Secure communication with your Mac
- **Keychain Storage**: Secure credential management
- **Encryption**: Data encryption using AES-256
- **Jailbreak Detection**: Protection against compromised devices

## Getting Started

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/privatehomeai.git
cd privatehomeai
```

2. Open the project in Xcode:
```bash
open Package.swift
```

3. Build and run the project on your iOS device or simulator.

### Setting Up Ollama

1. Install Ollama on your Mac:
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

2. Pull a model (e.g., Llama 2):
```bash
ollama pull llama2
```

3. Start the Ollama server:
```bash
ollama serve
```

## Usage

1. **Authentication**: Connect to your Mac by providing SSH credentials
2. **Chat**: Select a model and start chatting with your local LLM
3. **Devices**: View and manage connected devices
4. **Settings**: Configure app preferences and security settings

## Development

### Dependencies

- **Alamofire**: Network requests
- **CryptoSwift**: Encryption and hashing
- **NMSSH**: SSH connectivity

### Testing

Run the tests using Xcode's test navigator or via the command line:

```bash
swift test
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Ollama](https://ollama.com) for providing the local LLM server
- [Alamofire](https://github.com/Alamofire/Alamofire) for networking
- [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift) for encryption
- [NMSSH](https://github.com/NMSSH/NMSSH) for SSH connectivity 