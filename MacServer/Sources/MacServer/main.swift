import Foundation
import MacServerLib
import Logging

// Configure logging
LoggingSystem.bootstrap { label in
    var handler = StreamLogHandler.standardOutput(label: label)
    handler.logLevel = .info
    return handler
}

let logger = Logger(label: "com.nooku.macserver.main")
logger.info("Starting Nooku Mac Server")

// Start servers
logger.info("Starting API server")
if APIServer.shared.start(port: 8080) {
    logger.info("API server started on port \(APIServer.shared.port)")
} else {
    logger.error("Failed to start API server")
    exit(1)
}

logger.info("Starting SSH server")
if SSHServer.shared.start(port: 2222) {
    logger.info("SSH server started on port \(SSHServer.shared.port)")
} else {
    logger.error("Failed to start SSH server")
    exit(1)
}

// Print server information
logger.info("Nooku Mac Server is running")
logger.info("API server: http://localhost:\(APIServer.shared.port)")
logger.info("SSH server: ssh://localhost:\(SSHServer.shared.port)")

// Setup signal handling for graceful shutdown
signal(SIGINT) { _ in
    logger.info("Received interrupt signal, shutting down...")
    APIServer.shared.stop()
    SSHServer.shared.stop()
    exit(0)
}

signal(SIGTERM) { _ in
    logger.info("Received termination signal, shutting down...")
    APIServer.shared.stop()
    SSHServer.shared.stop()
    exit(0)
}

// Keep the process running
dispatchMain() 