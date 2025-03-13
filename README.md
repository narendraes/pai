# Private Home AI Assistant

A privacy-focused iOS application that enables secure home automation and AI interaction through local processing.

## Features

- Local LLM integration via home Mac
- Smart camera control and monitoring
- Privacy-focused architecture with no cloud dependency
- Secure SSH tunneling for communication
- Media analysis capabilities

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- Mac with Ollama installed (for LLM processing)

## Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/private-home-ai.git
cd private-home-ai
```

2. Open the project in Xcode
```bash
xed .
```

3. Build and run the application

## Architecture

The application follows the MVVM (Model-View-ViewModel) architecture pattern and is organized into the following components:

- **App**: Core application components
- **Features**: Feature-specific modules
  - Authentication
  - Chat
  - Camera
  - Analysis
  - Storage
- **Core**: Shared services and utilities
  - Network
  - Security
  - Utils
- **Resources**: Assets and resources

## Development

### Swift Package Manager

The project uses Swift Package Manager for dependency management. The main dependencies include:

- Alamofire: Network requests
- NMSSH: SSH connection
- CryptoSwift: Encryption
- SDWebImage: Image handling
- SwiftUIX: UI components

### Testing

Run the tests using:

```bash
swift test
```

## License

This project is licensed under the MIT License - see the LICENSE file for details. 