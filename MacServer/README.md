# Nooku Mac Server

The Mac server component for the Nooku app, providing camera access and streaming capabilities to iOS devices.

## Features

- **Camera Access**: Access and control Mac webcams and external cameras
- **Video Streaming**: Stream video from Mac cameras to iOS devices
- **Secure Communication**: SSH server for secure device communication
- **RESTful API**: HTTP API for camera control and streaming
- **Authentication**: Secure API access with API keys

## Requirements

- macOS 12.0 or later
- Swift 5.7 or later
- Xcode 14.0 or later

## Installation

### Using Swift Package Manager

```bash
git clone https://github.com/yourusername/nooku.git
cd nooku/MacServer
swift build
```

### Running the Server

```bash
swift run MacServer
```

By default, the server will start on port 8080 for the API and port 2222 for SSH.

## Architecture

The Mac server component consists of several key modules:

- **CameraManager**: Handles camera access and frame capture
- **StreamManager**: Manages video streaming sessions
- **SSHServer**: Provides secure communication channel
- **APIServer**: Exposes RESTful API endpoints

## API Endpoints

### Camera Endpoints

- `GET /api/v1/cameras`: List available cameras
- `GET /api/v1/cameras/snapshot`: Take a snapshot from the current camera
- `POST /api/v1/cameras/select`: Select a specific camera

### Stream Endpoints

- `GET /api/v1/streams`: List active streams
- `POST /api/v1/streams`: Start a new stream
- `DELETE /api/v1/streams/:streamId`: Stop a stream
- `GET /api/v1/streams/:streamId/frame`: Get the next frame from a stream

### SSH Endpoints

- `GET /api/v1/ssh/status`: Get SSH server status
- `POST /api/v1/ssh/start`: Start SSH server
- `POST /api/v1/ssh/stop`: Stop SSH server
- `GET /api/v1/ssh/keys`: List authorized keys
- `POST /api/v1/ssh/keys`: Add authorized key
- `DELETE /api/v1/ssh/keys/:keyId`: Remove authorized key

## Authentication

API requests require an API key to be included in the `X-API-Key` header.

## Development

### Building

```bash
swift build
```

### Testing

```bash
swift test
```

### Generating Xcode Project

```bash
swift package generate-xcodeproj
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request 