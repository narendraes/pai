import SwiftUI
import SVGKit

/// Error types that can occur when working with SVG images
public enum SVGError: Error, LocalizedError {
    case fileNotFound(String)
    case loadingFailed(String)
    case renderingFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "Could not find SVG file: \(name)"
        case .loadingFailed(let name):
            return "Failed to load SVG file: \(name)"
        case .renderingFailed(let name):
            return "Failed to render SVG: \(name)"
        }
    }
}

/// A SwiftUI view that renders SVG images using SVGKit
public struct SVGImageView: UIViewRepresentable {
    /// The name of the SVG file (without extension)
    private let svgName: String
    
    /// The size to render the SVG image
    private let size: CGSize?
    
    /// The tint color to apply to the SVG (if applicable)
    private let tintColor: UIColor?
    
    /// Optional placeholder to show when SVG fails to load
    private let placeholderImage: UIImage?
    
    /// View model that handles SVG loading and caching
    @ObservedObject private var viewModel: SVGImageViewModel
    
    /// Creates a new SVGImageView
    /// - Parameters:
    ///   - svgName: The name of the SVG file (without extension)
    ///   - size: Optional size to render the SVG image
    ///   - tintColor: Optional tint color to apply to the SVG
    ///   - placeholderImage: Optional image to display if SVG loading fails
    public init(svgName: String, 
                size: CGSize? = nil, 
                tintColor: Color? = nil,
                placeholderImage: UIImage? = nil) {
        self.svgName = svgName
        self.size = size
        self.tintColor = tintColor.map { UIColor($0) }
        self.placeholderImage = placeholderImage
        self.viewModel = SVGImageViewModel(svgName: svgName)
    }
    
    public func makeUIView(context: Context) -> SVGKFastImageView {
        // Create the image view
        let imageView: SVGKFastImageView
        
        do {
            // Try to load the SVG using the view model
            let svgImage = try viewModel.loadSVG()
            
            // Create a view with the loaded image
            guard let view = SVGKFastImageView(svgkImage: svgImage) else {
                // If view creation fails, throw an error
                throw SVGError.renderingFailed(svgName)
            }
            
            imageView = view
            
            // Configure the image view
            if let size = size {
                imageView.bounds = CGRect(origin: .zero, size: size)
            }
            
            if let tintColor = tintColor {
                imageView.tintColor = tintColor
            }
            
            // Log successful load for debugging
            #if DEBUG
            print("Successfully loaded SVG: \(svgName)")
            #endif
            
        } catch {
            // Handle error by creating a fallback view
            #if DEBUG
            print("SVG loading error: \(error.localizedDescription)")
            #endif
            
            if let placeholderImage = placeholderImage {
                // Create an empty SVGKImage from the placeholder UIImage
                let emptyView = SVGKFastImageView(frame: size.map { CGRect(origin: .zero, size: $0) } ?? .zero)
                // We can't directly set the image property with a UIImage
                // Use a UIImageView as the backing for the empty view
                let placeholderImageView = UIImageView(image: placeholderImage)
                placeholderImageView.contentMode = .scaleAspectFit
                placeholderImageView.frame = emptyView.bounds
                emptyView.addSubview(placeholderImageView)
                emptyView.backgroundColor = .clear
                imageView = emptyView
            } else {
                // Create a minimal empty view
                let emptyView = SVGKFastImageView(frame: .zero)
                emptyView.backgroundColor = .clear
                imageView = emptyView
            }
        }
        
        return imageView
    }
    
    public func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        // Update size if needed
        if let size = size, uiView.bounds.size != size {
            uiView.bounds = CGRect(origin: .zero, size: size)
            
            // If this is a placeholder view with a UIImageView, update that too
            if let imageView = uiView.subviews.first as? UIImageView {
                imageView.frame = uiView.bounds
            }
        }
        
        // Update tint color if needed
        if let tintColor = tintColor, uiView.tintColor != tintColor {
            uiView.tintColor = tintColor
        }
    }
    
    // MARK: - Static Methods
    
    /// Returns a placeholder view when SVG loading fails
    /// - Parameter systemName: SF Symbol name to use as placeholder
    /// - Returns: A view displaying the system image
    public static func placeholder(systemName: String) -> some View {
        Image(systemName: systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.gray)
    }
}

// MARK: - SwiftUI Previews
struct SVGImageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview with valid SVG
            SVGImageView(svgName: "example", size: CGSize(width: 100, height: 100))
                .previewDisplayName("Valid SVG")
            
            // Preview with invalid SVG - should show placeholder
            SVGImageView(svgName: "nonexistent", 
                        size: CGSize(width: 100, height: 100),
                        placeholderImage: UIImage(systemName: "exclamationmark.triangle"))
                .previewDisplayName("Invalid SVG with Placeholder")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 
