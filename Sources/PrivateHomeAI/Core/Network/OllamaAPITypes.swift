import Foundation

/// Represents a chat message for Ollama API
struct OllamaAPIMessage: Codable, Identifiable {
    var id: UUID
    let role: OllamaAPIMessageRole
    let content: String
    var model: String?
    var isFromUser: Bool {
        return role == .user
    }
    
    init(role: OllamaAPIMessageRole, content: String, model: String? = nil) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.model = model
    }
    
    /// API representation for Ollama API
    var apiRepresentation: [String: String] {
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        role = try container.decode(OllamaAPIMessageRole.self, forKey: .role)
        content = try container.decode(String.self, forKey: .content)
        model = try container.decodeIfPresent(String.self, forKey: .model)
        id = UUID()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(role, forKey: .role)
        try container.encode(content, forKey: .content)
        try container.encodeIfPresent(model, forKey: .model)
    }
}

/// Role of a message in a chat for Ollama API
enum OllamaAPIMessageRole: String, Codable {
    case system
    case user
    case assistant
} 