import Foundation
import os.log

/// A centralized logging service for the Private Home AI app
public class LoggingService {
    /// Shared instance for singleton access
    public static let shared = LoggingService()
    
    /// Log categories for different parts of the app
    public enum LogCategory: String {
        case general = "General"
        case network = "Network"
        case security = "Security"
        case authentication = "Authentication"
        case storage = "Storage"
        case ui = "UI"
        case camera = "Camera"
        case analysis = "Analysis"
        case chat = "Chat"
        case startup = "Startup"
    }
    
    /// Log levels for different severity of messages
    public enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case critical = "CRITICAL"
        
        var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .info:
                return .info
            case .warning:
                return .default
            case .error:
                return .error
            case .critical:
                return .fault
            }
        }
    }
    
    // Private loggers for each category
    private var loggers: [LogCategory: OSLog] = [:]
    
    // File URL for log file
    private let logFileURL: URL
    
    // Date formatter for log entries
    private let dateFormatter: DateFormatter
    
    // Queue for file operations
    private let logQueue = DispatchQueue(label: "com.privateai.home.logging", qos: .utility)
    
    // Private initializer for singleton
    private init() {
        // Initialize date formatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        // Create loggers for each category
        for category in LogCategory.allCases {
            loggers[category] = OSLog(subsystem: "com.privateai.home", category: category.rawValue)
        }
        
        // Set up log file in Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        logFileURL = documentsDirectory.appendingPathComponent("Nooku.log")
        
        // Create log file if it doesn't exist
        if !FileManager.default.fileExists(atPath: logFileURL.path) {
            FileManager.default.createFile(atPath: logFileURL.path, contents: nil, attributes: nil)
        }
        
        // Log startup
        log(category: .startup, level: .info, message: "Logging service initialized")
    }
    
    /// Log a message with the specified category and level
    /// - Parameters:
    ///   - category: The category of the log message
    ///   - level: The severity level of the log message
    ///   - message: The message to log
    ///   - file: The file where the log was called from (automatically provided)
    ///   - function: The function where the log was called from (automatically provided)
    ///   - line: The line number where the log was called from (automatically provided)
    public func log(category: LogCategory, level: LogLevel, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        // Get logger for category
        let logger = loggers[category] ?? OSLog.default
        
        // Log to system
        os_log("%{public}@", log: logger, type: level.osLogType, message)
        
        // Format message for file
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let formattedDate = dateFormatter.string(from: Date())
        let logMessage = "[\(formattedDate)] [\(level.rawValue)] [\(category.rawValue)] [\(fileName):\(line) \(function)] \(message)\n"
        
        // Write to file asynchronously
        logQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let data = logMessage.data(using: .utf8) {
                if let fileHandle = try? FileHandle(forWritingTo: self.logFileURL) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            }
        }
    }
    
    /// Get the contents of the log file
    /// - Returns: The contents of the log file as a string
    public func getLogContents() -> String {
        do {
            return try String(contentsOf: logFileURL, encoding: .utf8)
        } catch {
            return "Error reading log file: \(error.localizedDescription)"
        }
    }
    
    /// Clear the log file
    public func clearLogs() {
        logQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                try "".write(to: self.logFileURL, atomically: true, encoding: .utf8)
                self.log(category: .general, level: .info, message: "Log file cleared")
            } catch {
                self.log(category: .general, level: .error, message: "Failed to clear log file: \(error.localizedDescription)")
            }
        }
    }
}

// Extension to make LogCategory conform to CaseIterable
extension LoggingService.LogCategory: CaseIterable {} 