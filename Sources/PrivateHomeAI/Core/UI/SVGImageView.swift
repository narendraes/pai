import SwiftUI
import SVGKit

/// A SwiftUI view that renders SVG images using SVGKit
public struct SVGImageView: UIViewRepresentable {
    /// The name of the SVG file (without extension)
    private let svgName: String
    
    /// The size to render the SVG image
    private let size: CGSize?
    
    /// The tint color to apply to the SVG (if applicable)
    private let tintColor: UIColor?
    
    /// Creates a new SVGImageView
    /// - Parameters:
    ///   - svgName: The name of the SVG file (without extension)
    ///   - size: Optional size to render the SVG image
    ///   - tintColor: Optional tint color to apply to the SVG
    public init(svgName: String, size: CGSize? = nil, tintColor: Color? = nil) {
        self.svgName = svgName
        self.size = size
        self.tintColor = tintColor.map { UIColor($0) }
    }
    
    public func makeUIView(context: Context) -> SVGKFastImageView {
        // First try to load from the SVGs directory
        var svgURL: URL?
        
        // Try to find the SVG in the SVGs directory
        if let url = Bundle.main.url(forResource: "SVGs/\(svgName)", withExtension: "svg") {
            svgURL = url
        } 
        // Fallback to looking in the main bundle
        else if let url = Bundle.main.url(forResource: svgName, withExtension: "svg") {
            svgURL = url
        }
        
        guard let svgURL = svgURL else {
            print("Error: Could not find SVG file named \(svgName).svg")
            // Return an empty view if the SVG file is not found
            return SVGKFastImageView()
        }
        
        let svgImage = SVGKImage(contentsOf: svgURL)
        let imageView = SVGKFastImageView(svgkImage: svgImage!)
        
        // Apply size if provided
        if let size = size {
            imageView.frame = CGRect(origin: .zero, size: size)
        }
        
        // Apply tint color if provided
        if let tintColor = tintColor {
            imageView.tintColor = tintColor
        }
        
        return imageView
    }
    
    public func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        // Update size if needed
        if let size = size, uiView.frame.size != size {
            uiView.frame = CGRect(origin: .zero, size: size)
        }
        
        // Update tint color if needed
        if let tintColor = tintColor, uiView.tintColor != tintColor {
            uiView.tintColor = tintColor
        }
    }
}

// MARK: - Previews
struct SVGImageView_Previews: PreviewProvider {
    static var previews: some View {
        SVGImageView(svgName: "example", size: CGSize(width: 100, height: 100))
            .previewLayout(.sizeThatFits)
            .padding()
    }
} 