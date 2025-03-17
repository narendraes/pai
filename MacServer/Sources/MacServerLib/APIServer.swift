import Foundation
import Vapor
import Logging

/// Manages the HTTP API server for the Mac server component
public class APIServer {
    // MARK: - Properties
    
    /// Shared singleton instance
    public static let shared = APIServer()
    
    /// Logger for API operations
    private let logger = Logger(label: "com.nooku.macserver.api")
    
    /// Vapor application instance
    private var app: Application?
    
    /// Server status
    private(set) public var isRunning = false
    
    /// Server port
    private(set) public var port: Int = 8080
    
    // MARK: - Initialization
    
    private init() {
        logger.info("APIServer initialized")
    }
    
    // MARK: - Public Methods
    
    /// Start the API server
    /// - Parameter port: Port to listen on (default: 8080)
    /// - Returns: True if successfully started, false otherwise
    public func start(port: Int = 8080) -> Bool {
        logger.info("Starting API server on port \(port)")
        
        guard !isRunning else {
            logger.warning("API server already running")
            return true
        }
        
        do {
            // Create Vapor application
            let app = Application(.development)
            app.http.server.configuration.port = port
            
            // Configure routes
            configureRoutes(app)
            
            // Start the server
            try app.start()
            
            self.app = app
            self.port = port
            isRunning = true
            
            logger.info("API server started on port \(port)")
            return true
        } catch {
            logger.error("Failed to start API server: \(error)")
            return false
        }
    }
    
    /// Stop the API server
    public func stop() {
        logger.info("Stopping API server")
        
        guard isRunning, let app = app else {
            logger.warning("API server not running")
            return
        }
        
        app.shutdown()
        self.app = nil
        isRunning = false
        
        logger.info("API server stopped")
    }
    
    // MARK: - Private Methods
    
    private func configureRoutes(_ app: Application) {
        // Configure CORS
        let corsConfiguration = CORSMiddleware.Configuration(
            allowedOrigin: .all,
            allowedMethods: [.GET, .POST, .PUT, .DELETE],
            allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
        )
        app.middleware.use(CORSMiddleware(configuration: corsConfiguration))
        
        // Configure authentication
        app.middleware.use(AuthMiddleware())
        
        // Health check endpoint
        app.get("health") { req -> String in
            return "OK"
        }
        
        // API version endpoint
        app.get("version") { req -> APIResponse<VersionInfo> in
            return APIResponse(
                success: true,
                data: VersionInfo(
                    version: "1.0.0",
                    buildNumber: "1",
                    apiVersion: "v1"
                )
            )
        }
        
        // Camera endpoints
        configureCameraRoutes(app)
        
        // Stream endpoints
        configureStreamRoutes(app)
        
        // SSH endpoints
        configureSSHRoutes(app)
        
        // Catch-all for undefined routes
        app.get(PathComponent.catchall) { req -> APIResponse<EmptyResponse> in
            throw Abort(.notFound, reason: "Endpoint not found")
        }
        
        // Error handling
        app.middleware.use(ErrorMiddleware.custom(environment: app.environment))
    }
    
    private func configureCameraRoutes(_ app: Application) {
        let cameras = app.grouped("api", "v1", "cameras")
        
        // List available cameras
        cameras.get { req -> APIResponse<[CameraInfo]> in
            let cameraList = CameraManager.shared.listCameras()
            return APIResponse(success: true, data: cameraList)
        }
        
        // Get camera snapshot
        cameras.get("snapshot") { req -> Response in
            guard let imageData = CameraManager.shared.takeSnapshot() else {
                throw Abort(.internalServerError, reason: "Failed to capture snapshot")
            }
            
            let response = Response(status: .ok)
            response.headers.contentType = .jpeg
            response.body = Response.Body(data: imageData)
            return response
        }
        
        // Select camera
        cameras.post("select") { req -> APIResponse<EmptyResponse> in
            struct SelectRequest: Content {
                let cameraId: String
            }
            
            let selectRequest = try req.content.decode(SelectRequest.self)
            
            guard CameraManager.shared.selectCamera(cameraId: selectRequest.cameraId) else {
                throw Abort(.badRequest, reason: "Failed to select camera")
            }
            
            return APIResponse(success: true, data: EmptyResponse())
        }
    }
    
    private func configureStreamRoutes(_ app: Application) {
        let streams = app.grouped("api", "v1", "streams")
        
        // List active streams
        streams.get { req -> APIResponse<[StreamInfo]> in
            let streamList = StreamManager.shared.getActiveStreams()
            return APIResponse(success: true, data: streamList)
        }
        
        // Start a new stream
        streams.post { req -> APIResponse<StreamResponse> in
            struct StreamRequest: Content {
                let quality: StreamQuality
                let frameRate: Int
            }
            
            let streamRequest = try req.content.decode(StreamRequest.self)
            
            guard let streamId = StreamManager.shared.startStream(
                quality: streamRequest.quality,
                frameRate: streamRequest.frameRate
            ) else {
                throw Abort(.internalServerError, reason: "Failed to start stream")
            }
            
            return APIResponse(
                success: true,
                data: StreamResponse(
                    streamId: streamId,
                    streamUrl: "/api/v1/streams/\(streamId.uuidString)/frame"
                )
            )
        }
        
        // Stop a stream
        streams.delete(":streamId") { req -> APIResponse<EmptyResponse> in
            guard let streamIdString = req.parameters.get("streamId"),
                  let streamId = UUID(uuidString: streamIdString) else {
                throw Abort(.badRequest, reason: "Invalid stream ID")
            }
            
            StreamManager.shared.stopStream(sessionId: streamId)
            
            return APIResponse(success: true, data: EmptyResponse())
        }
        
        // Get stream frame
        streams.get(":streamId", "frame") { req -> Response in
            guard let streamIdString = req.parameters.get("streamId"),
                  let streamId = UUID(uuidString: streamIdString) else {
                throw Abort(.badRequest, reason: "Invalid stream ID")
            }
            
            guard let frameData = StreamManager.shared.getNextFrame(sessionId: streamId) else {
                throw Abort(.notFound, reason: "No frame available")
            }
            
            let response = Response(status: .ok)
            response.headers.contentType = .jpeg
            response.body = Response.Body(data: frameData)
            return response
        }
    }
    
    private func configureSSHRoutes(_ app: Application) {
        let ssh = app.grouped("api", "v1", "ssh")
        
        // Get SSH server status
        ssh.get("status") { req -> APIResponse<SSHStatusResponse> in
            return APIResponse(
                success: true,
                data: SSHStatusResponse(
                    running: SSHServer.shared.isRunning,
                    port: SSHServer.shared.port,
                    connections: SSHServer.shared.getActiveConnections().count
                )
            )
        }
        
        // Start SSH server
        ssh.post("start") { req -> APIResponse<SSHStatusResponse> in
            struct StartRequest: Content {
                let port: UInt16?
            }
            
            let startRequest = try req.content.decode(StartRequest.self)
            let port = startRequest.port ?? 2222
            
            guard SSHServer.shared.start(port: port) else {
                throw Abort(.internalServerError, reason: "Failed to start SSH server")
            }
            
            return APIResponse(
                success: true,
                data: SSHStatusResponse(
                    running: SSHServer.shared.isRunning,
                    port: SSHServer.shared.port,
                    connections: SSHServer.shared.getActiveConnections().count
                )
            )
        }
        
        // Stop SSH server
        ssh.post("stop") { req -> APIResponse<SSHStatusResponse> in
            SSHServer.shared.stop()
            
            return APIResponse(
                success: true,
                data: SSHStatusResponse(
                    running: SSHServer.shared.isRunning,
                    port: SSHServer.shared.port,
                    connections: 0
                )
            )
        }
        
        // List authorized keys
        ssh.get("keys") { req -> APIResponse<[AuthorizedKeyResponse]> in
            let keys = SSHServer.shared.getAuthorizedKeys()
            let keyResponses = keys.map { key in
                AuthorizedKeyResponse(
                    id: key.id,
                    comment: key.comment,
                    createdAt: key.createdAt
                )
            }
            
            return APIResponse(success: true, data: keyResponses)
        }
        
        // Add authorized key
        ssh.post("keys") { req -> APIResponse<AuthorizedKeyResponse> in
            struct KeyRequest: Content {
                let key: String
                let comment: String?
            }
            
            let keyRequest = try req.content.decode(KeyRequest.self)
            
            guard let keyData = Data(base64Encoded: keyRequest.key) else {
                throw Abort(.badRequest, reason: "Invalid key data")
            }
            
            guard SSHServer.shared.addAuthorizedKey(key: keyData, comment: keyRequest.comment) else {
                throw Abort(.internalServerError, reason: "Failed to add key")
            }
            
            // Get the newly added key (last one in the list)
            guard let newKey = SSHServer.shared.getAuthorizedKeys().last else {
                throw Abort(.internalServerError, reason: "Key was added but not found")
            }
            
            return APIResponse(
                success: true,
                data: AuthorizedKeyResponse(
                    id: newKey.id,
                    comment: newKey.comment,
                    createdAt: newKey.createdAt
                )
            )
        }
        
        // Remove authorized key
        ssh.delete("keys", ":keyId") { req -> APIResponse<EmptyResponse> in
            guard let keyIdString = req.parameters.get("keyId"),
                  let keyId = UUID(uuidString: keyIdString) else {
                throw Abort(.badRequest, reason: "Invalid key ID")
            }
            
            guard SSHServer.shared.removeAuthorizedKey(id: keyId) else {
                throw Abort(.notFound, reason: "Key not found")
            }
            
            return APIResponse(success: true, data: EmptyResponse())
        }
    }
}

// MARK: - API Response

/// Generic API response structure
public struct APIResponse<T: Content>: Content {
    public let success: Bool
    public let data: T
    public let error: String?
    
    public init(success: Bool, data: T, error: String? = nil) {
        self.success = success
        self.data = data
        self.error = error
    }
}

// MARK: - Response Models

/// Empty response for endpoints that don't return data
public struct EmptyResponse: Content {}

/// Version information response
public struct VersionInfo: Content {
    public let version: String
    public let buildNumber: String
    public let apiVersion: String
}

/// Stream response with stream ID and URL
public struct StreamResponse: Content {
    public let streamId: UUID
    public let streamUrl: String
}

/// SSH server status response
public struct SSHStatusResponse: Content {
    public let running: Bool
    public let port: UInt16
    public let connections: Int
}

/// Authorized key response
public struct AuthorizedKeyResponse: Content {
    public let id: UUID
    public let comment: String?
    public let createdAt: Date
}

// MARK: - Middleware

/// Authentication middleware
struct AuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // Skip authentication for health check and version endpoints
        if request.url.path == "/health" || request.url.path == "/version" {
            return next.respond(to: request)
        }
        
        // Check for API key in header
        guard let apiKey = request.headers.first(name: "X-API-Key") else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Missing API key"))
        }
        
        // In a real implementation, validate the API key against a secure store
        // For this example, we'll use a simple check
        if apiKey != "test-api-key" {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Invalid API key"))
        }
        
        return next.respond(to: request)
    }
}

// MARK: - Custom Error Middleware

extension ErrorMiddleware {
    static func custom(environment: Environment) -> ErrorMiddleware {
        return .init { req, error in
            let status: HTTPResponseStatus
            let reason: String
            let headers: HTTPHeaders
            
            switch error {
            case let abort as AbortError:
                reason = abort.reason
                status = abort.status
                headers = abort.headers
            case let validation as ValidationsError:
                reason = validation.description
                status = .badRequest
                headers = [:]
            default:
                reason = environment.isRelease ? "Something went wrong" : error.localizedDescription
                status = .internalServerError
                headers = [:]
            }
            
            let response = Response(status: status, headers: headers)
            
            do {
                let apiResponse = APIResponse<EmptyResponse>(
                    success: false,
                    data: EmptyResponse(),
                    error: reason
                )
                
                try response.content.encode(apiResponse)
                return response
            } catch {
                return Response(status: .internalServerError, body: .init(string: "Error: \(error)"))
            }
        }
    }
} 