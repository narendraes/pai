private func configureRoutes(_ app: Application) {
    // Configure CORS to be very permissive for testing
    app.middleware.use(CORSMiddleware(configuration: .init(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: ["*"],
        allowCredentials: false
    )))
    
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