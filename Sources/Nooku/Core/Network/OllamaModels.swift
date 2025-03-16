import Foundation

/// Represents an Ollama model
public struct OllamaModelInfo: Codable, Identifiable, Hashable {
    public var id: String { name }
    public let name: String
    public let size: Int64
    public let modified: Date
    
    enum CodingKeys: String, CodingKey {
        case name
        case size
        case modified = "modified_at"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        size = try container.decode(Int64.self, forKey: .size)
        
        let modifiedString = try container.decode(String.self, forKey: .modified)
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: modifiedString) {
            modified = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .modified, in: container, debugDescription: "Date format is invalid")
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    public static func == (lhs: OllamaModelInfo, rhs: OllamaModelInfo) -> Bool {
        return lhs.name == rhs.name
    }
}

/// Response from Ollama list models API
public struct OllamaListModelsResponse: Codable {
    public let models: [OllamaModelInfo]
}

/// Represents a chat message for Ollama API
public struct OllamaMessage: Codable, Identifiable {
    public var id: UUID
    public let role: OllamaMessageRole
    public let content: String
    public var model: String?
    public var isFromUser: Bool {
        return role == .user
    }
    
    public init(role: OllamaMessageRole, content: String, model: String? = nil) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.model = model
    }
    
    /// API representation for Ollama API
    public var apiRepresentation: [String: String] {
        [
            "role": role.rawValue,
            "content": content
        ]
    }
    
    enum CodingKeys: String, CodingKey {
        case role
        case content
        case model
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        role = try container.decode(OllamaMessageRole.self, forKey: .role)
        content = try container.decode(String.self, forKey: .content)
        model = try container.decodeIfPresent(String.self, forKey: .model)
        id = UUID()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(role, forKey: .role)
        try container.encode(content, forKey: .content)
        try container.encodeIfPresent(model, forKey: .model)
    }
}

/// Role of a message in a chat
public enum OllamaMessageRole: String, Codable {
    case system
    case user
    case assistant
} 