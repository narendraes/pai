import SwiftUI

/// Extension to provide a convenient way to use SVG images in SwiftUI
public extension Image {
    /// Creates an Image from an SVG file
    /// - Parameters:
    ///   - svgName: The name of the SVG file (without extension)
    ///   - size: Optional size to render the SVG image
    ///   - tintColor: Optional tint color to apply to the SVG
    /// - Returns: A SwiftUI Image view that wraps the SVG
    static func svg(_ svgName: String, size: CGSize? = nil, tintColor: Color? = nil) -> some View {
        SVGImageView(svgName: svgName, size: size, tintColor: tintColor)
    }
} 