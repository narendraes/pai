import Foundation

struct Camera: Identifiable {
    let id: String
    let name: String
    let isOnline: Bool
    let type: CameraType
    
    init(id: String, name: String, isOnline: Bool, type: CameraType = .external) {
        self.id = id
        self.name = name
        self.isOnline = isOnline
        self.type = type
    }
}

enum CameraType {
    case device // Built-in device camera
    case external // External IP camera
} 