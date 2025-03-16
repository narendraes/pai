import SwiftUI
import Combine

/// Loads images asynchronously from the bundle or file system
public class ImageLoader: ObservableObject {
    /// The loaded image
    @Published public var image: UIImage?
    
    /// Loading state
    @Published public var isLoading = false
    
    /// Error message if loading failed
    @Published public var errorMessage: String?
    
    /// Cache for loaded images
    private static var imageCache = NSCache<NSString, UIImage>()
    
    private var cancellable: AnyCancellable?
    private let imageName: String
    
    /// Initialize with an image name
    /// - Parameter imageName: Name of the image without extension
    public init(imageName: String) {
        self.imageName = imageName
        loadImage()
    }
    
    private func loadImage() {
        // Check cache first
        let cacheKey = NSString(string: imageName)
        if let cachedImage = Self.imageCache.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Run in background
        cancellable = Future<UIImage?, Error> { promise in
            // Try loading from bundle
            if let image = UIImage(named: self.imageName) {
                promise(.success(image))
                return
            }
            
            // Try with extensions
            for ext in ["jpg", "jpeg", "png"] {
                if let url = Bundle.main.url(forResource: self.imageName, withExtension: ext),
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    promise(.success(image))
                    return
                }
            }
            
            // Check in subfolders
            let searchPaths = [
                "Images/\(self.imageName)",
                "Resources/Images/\(self.imageName)"
            ]
            
            for path in searchPaths {
                for ext in ["jpg", "jpeg", "png"] {
                    if let url = Bundle.main.url(forResource: path, withExtension: ext),
                       let data = try? Data(contentsOf: url),
                       let image = UIImage(data: data) {
                        promise(.success(image))
                        return
                    }
                }
            }
            
            // Failed to find image
            promise(.failure(ImageError.notFound(self.imageName)))
        }
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    if let imageError = error as? ImageError {
                        self?.errorMessage = imageError.localizedDescription
                    } else {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            },
            receiveValue: { [weak self] image in
                guard let self = self, let image = image else { return }
                
                // Cache the loaded image
                let cacheKey = NSString(string: self.imageName)
                Self.imageCache.setObject(image, forKey: cacheKey)
                
                self.image = image
            }
        )
    }
    
    /// Clear all cached images
    public static func clearCache() {
        imageCache.removeAllObjects()
    }
    
    deinit {
        cancellable?.cancel()
    }
}

/// Errors that can occur when loading images
public enum ImageError: Error, LocalizedError {
    case notFound(String)
    case loadingFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .notFound(let name):
            return "Image not found: \(name)"
        case .loadingFailed(let name):
            return "Failed to load image: \(name)"
        }
    }
} 