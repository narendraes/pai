import SwiftUI

/// A SwiftUI view for displaying images with loading and error states
public struct ImageView: View {
    /// The image loader that handles loading the image
    @StateObject private var loader: ImageLoader
    
    /// Size for the image
    private let size: CGSize?
    
    /// Content mode for the image
    private let contentMode: ContentMode
    
    /// Tint color for rendering template images
    private let tintColor: Color?
    
    /// Create a new ImageView
    /// - Parameters:
    ///   - imageName: The name of the image file (without extension)
    ///   - size: Optional size for the image
    ///   - contentMode: Content mode for displaying the image (default: .fit)
    ///   - tintColor: Optional tint color for the image
    public init(
        imageName: String,
        size: CGSize? = nil,
        contentMode: ContentMode = .fit,
        tintColor: Color? = nil
    ) {
        self._loader = StateObject(wrappedValue: ImageLoader(imageName: imageName))
        self.size = size
        self.contentMode = contentMode
        self.tintColor = tintColor
    }
    
    public var body: some View {
        Group {
            if let image = loader.image {
                // Image loaded successfully
                if let tintColor = tintColor {
                    // Use template rendering mode with tint color
                    let templateImage = image.withRenderingMode(.alwaysTemplate)
                    Image(uiImage: templateImage)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                        .foregroundColor(tintColor)
                } else {
                    // Normal image rendering
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                }
            } else if loader.isLoading {
                // Loading indicator
                ProgressView()
            } else {
                // Error or placeholder state
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .foregroundColor(.gray)
                    .opacity(0.5)
            }
        }
        .frame(width: size?.width, height: size?.height)
    }
}

// Helper for conditional view modifiers
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Previews
struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Valid image
            ImageView(imageName: "app_logo", size: CGSize(width: 100, height: 100))
                .previewDisplayName("Valid Image")
            
            // Non-existent image
            ImageView(imageName: "nonexistent_image", size: CGSize(width: 100, height: 100))
                .previewDisplayName("Missing Image")
            
            // Tinted image
            ImageView(imageName: "app_logo", size: CGSize(width: 100, height: 100), tintColor: .blue)
                .previewDisplayName("Tinted Image")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 