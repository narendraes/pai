import SwiftUI

/// Extension to provide a fallback for SVG functionality
/// This has been replaced with standard SF Symbols for improved reliability
public extension Image {
    /// Creates an Image from a system symbol (fallback from SVG)
    /// - Parameters:
    ///   - svgName: DEPRECATED - Formerly the SVG name, now uses a mapping to system symbols
    ///   - size: DEPRECATED - Size is now controlled by frame modifiers
    ///   - tintColor: DEPRECATED - Color is now controlled by foregroundColor modifiers
    /// - Returns: A SwiftUI Image view using SF Symbols
    static func svg(_ svgName: String, size: CGSize? = nil, tintColor: Color? = nil) -> some View {
        // Map common SVG names to SF Symbols
        let systemName = mapSVGNameToSystemSymbol(svgName)
        
        return Image(systemName: systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(tintColor)
            .frame(width: size?.width, height: size?.height)
    }
    
    /// Maps SVG names to SF Symbol names
    /// - Parameter svgName: The former SVG name
    /// - Returns: A corresponding SF Symbol name
    private static func mapSVGNameToSystemSymbol(_ svgName: String) -> String {
        switch svgName {
        case "home_icon":
            return "house.fill"
        case "chat_icon", "message_icon":
            return "message.fill"
        case "devices_icon", "camera_icon":
            return "camera.fill"
        case "settings_icon", "gear_icon":
            return "gear"
        case "disconnected_icon":
            return "wifi.slash"
        case "error_icon", "warning_icon":
            return "exclamationmark.triangle.fill"
        case "connected_icon":
            return "wifi"
        default:
            // Fallback for unknown icons
            return "questionmark.circle"
        }
    }
} 