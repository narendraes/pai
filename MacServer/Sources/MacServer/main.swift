import Foundation
import MacServerLib
import Logging
import Lifecycle

// Configure logging
LoggingSystem.bootstrap { label in
    var handler = StreamLogHandler.standardOutput(label: label)
    handler.logLevel = .info
    return handler
}

let logger = Logger(label: "com.nooku.macserver.main")
logger.info("Starting Nooku Mac Server")

// Create service lifecycle
let lifecycle = ServiceLifecycle(configuration: .init(
    shutdownSignal: .sigterm
))

// Add API server to lifecycle
lifecycle.registerShutdown(
    label: "API Server",
    .sync { 
        logger.info("Shutting down API server")
        APIServer.shared.stop()
    }
)

// Add SSH server to lifecycle
lifecycle.registerShutdown(
    label: "SSH Server",
    .sync { 
        logger.info("Shutting down SSH server")
        SSHServer.shared.stop()
    }
)

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

// Start the lifecycle
do {
    try lifecycle.startAndWait()
} catch {
    logger.error("Service lifecycle error: \(error)")
    exit(1)
} 