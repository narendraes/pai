import Foundation
import SVGKit
import SwiftUI

/// View model for SVGImageView that handles loading and caching SVG images
public class SVGImageViewModel: ObservableObject {
    /// The name of the SVG file (without extension)
    public let svgName: String
    
    /// Published property that tracks loading status
    @Published private(set) var state: LoadingState = .idle
    
    /// Static cache to store loaded SVG images to improve performance
    private static var imageCache = NSCache<NSString, SVGKImage>()
    
    /// Maximum cache size in bytes (10MB)
    private static let maxCacheSize: Int = 10 * 1024 * 1024
    
    /// State of SVG loading process
    public enum LoadingState {
        case idle
        case loading
        case loaded(SVGKImage)
        case failed(Error)
    }
    
    /// Initializes the view model with an SVG file name
    /// - Parameter svgName: Name of the SVG file without extension
    public init(svgName: String) {
        self.svgName = svgName
        
        // Configure cache if not already done
        Self.configureCache()
    }
    
    /// Configures the static cache with size limits
    private static func configureCache() {
        // Set maximum cache size
        SVGImageViewModel.imageCache.totalCostLimit = maxCacheSize
    }
    
    /// Loads an SVG image from bundle or cache
    /// - Returns: Loaded SVGKImage
    /// - Throws: SVGError if loading fails
    public func loadSVG() throws -> SVGKImage {
        // Check if state already contains a loaded image
        if case .loaded(let image) = state {
            return image
        }
        
        // Set state to loading
        self.state = .loading
        
        // Check cache first
        let cacheKey = NSString(string: svgName)
        if let cachedImage = Self.imageCache.object(forKey: cacheKey) {
            self.state = .loaded(cachedImage)
            return cachedImage
        }
        
        // Find SVG URL
        var svgURL: URL?
        
        // Try to find the SVG in the SVGs directory
        if let url = Bundle.main.url(forResource: "SVGs/\(svgName)", withExtension: "svg") {
            svgURL = url
        } 
        // Fallback to looking in the main bundle
        else if let url = Bundle.main.url(forResource: svgName, withExtension: "svg") {
            svgURL = url
        }
        
        // Validate that URL exists
        guard let svgURL = svgURL else {
            let error = SVGError.fileNotFound(svgName)
            self.state = .failed(error)
            throw error
        }
        
        // Load SVG from URL
        guard let svgImage = SVGKImage(contentsOf: svgURL) else {
            let error = SVGError.loadingFailed(svgName)
            self.state = .failed(error)
            throw error
        }
        
        // Cache the image for future use
        // Calculate approximate memory size for the cache
        let memoryCost = Int(svgImage.size.width * svgImage.size.height * 4) // 4 bytes per pixel estimate
        Self.imageCache.setObject(svgImage, forKey: cacheKey, cost: memoryCost)
        
        // Update state
        self.state = .loaded(svgImage)
        
        return svgImage
    }
    
    /// Clears the cache for a specific SVG
    /// - Parameter name: Name of the SVG to clear from cache
    public static func clearCache(for name: String) {
        let cacheKey = NSString(string: name)
        imageCache.removeObject(forKey: cacheKey)
    }
    
    /// Clears the entire SVG cache
    public static func clearAllCache() {
        imageCache.removeAllObjects()
    }
}

// Extension for accessing SVG resources
extension Bundle {
    /// Gets a URL for an SVG in the specified bundle
    /// - Parameters:
    ///   - name: SVG file name without extension
    ///   - searchPaths: Array of paths to search for the SVG
    /// - Returns: URL to the SVG file if found
    public func svgURL(named name: String, searchPaths: [String] = ["SVGs", ""]) -> URL? {
        for path in searchPaths {
            let resourcePath = path.isEmpty ? name : "\(path)/\(name)"
            if let url = self.url(forResource: resourcePath, withExtension: "svg") {
                return url
            }
        }
        return nil
    }
} 