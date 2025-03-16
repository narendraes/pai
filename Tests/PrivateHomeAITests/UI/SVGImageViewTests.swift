import XCTest
import SwiftUI
import SVGKit
@testable import PrivateHomeAI

final class SVGImageViewTests: XCTestCase {
    
    // Test SVG name for testing
    let validSVGName = "test_valid"
    let invalidSVGName = "test_invalid"
    
    // Setup test SVG data
    override func setUp() {
        super.setUp()
        // Clear cache before each test
        SVGImageViewModel.clearAllCache()
        
        // Register a mock SVG for testing
        MockSVGProvider.registerSVGForTests(named: validSVGName)
        
        // Swizzle the Bundle.url method for testing
        swizzleBundleURLMethod()
    }
    
    // Cleanup after tests
    override func tearDown() {
        // Clear cache after each test
        SVGImageViewModel.clearAllCache()
        
        // Restore original Bundle.url method
        restoreBundleURLMethod()
        
        super.tearDown()
    }
    
    // MARK: - View Model Tests
    
    func testViewModelLoadsValidSVG() throws {
        // Create view model with valid SVG
        let viewModel = SVGImageViewModel(svgName: validSVGName)
        
        // Load SVG
        do {
            let svgImage = try viewModel.loadSVG()
            XCTAssertNotNil(svgImage, "SVG should load successfully")
            
            // State should be .loaded
            if case .loaded(let loadedImage) = viewModel.state {
                XCTAssertEqual(loadedImage, svgImage, "Loaded image should match returned image")
            } else {
                XCTFail("State should be .loaded")
            }
        } catch {
            XCTFail("Loading valid SVG should not throw: \(error)")
        }
    }
    
    func testViewModelHandlesInvalidSVG() {
        // Create view model with invalid SVG
        let viewModel = SVGImageViewModel(svgName: invalidSVGName)
        
        // Attempt to load SVG
        do {
            _ = try viewModel.loadSVG()
            XCTFail("Loading invalid SVG should throw")
        } catch let error as SVGError {
            // Should throw SVGError.fileNotFound
            if case SVGError.fileNotFound(let name) = error {
                XCTAssertEqual(name, invalidSVGName, "Error should contain SVG name")
            } else {
                XCTFail("Error should be fileNotFound")
            }
            
            // State should be .failed
            if case .failed(let failedError) = viewModel.state {
                XCTAssertTrue(failedError is SVGError, "Failed error should be SVGError")
            } else {
                XCTFail("State should be .failed")
            }
        } catch {
            XCTFail("Should throw SVGError, not \(type(of: error))")
        }
    }
    
    func testCachingBehavior() throws {
        // Load SVG first time
        let viewModel1 = SVGImageViewModel(svgName: validSVGName)
        let image1 = try viewModel1.loadSVG()
        
        // Create new view model for same SVG
        let viewModel2 = SVGImageViewModel(svgName: validSVGName)
        let image2 = try viewModel2.loadSVG()
        
        // Should be same object reference due to caching
        XCTAssertTrue(image1 === image2, "Images should be same instance from cache")
        
        // Clear cache
        SVGImageViewModel.clearCache(for: validSVGName)
        
        // Load again should return new instance
        let viewModel3 = SVGImageViewModel(svgName: validSVGName)
        let image3 = try viewModel3.loadSVG()
        
        // Should not be same object reference
        XCTAssertFalse(image1 === image3, "Images should be different instances after clearing cache")
    }
    
    // MARK: - View Tests
    
    func testViewCreation() {
        // Create view with valid SVG
        let view = SVGImageView(svgName: validSVGName, size: CGSize(width: 100, height: 100))
        XCTAssertNotNil(view, "View should be created successfully")
        
        // Create view with invalid SVG
        let invalidView = SVGImageView(svgName: invalidSVGName, size: CGSize(width: 100, height: 100))
        XCTAssertNotNil(invalidView, "View should be created even with invalid SVG name")
    }
    
    // MARK: - Method Swizzling for Testing
    
    private var originalBundleURLMethod: Method?
    
    private func swizzleBundleURLMethod() {
        // This would actually implement method swizzling to intercept Bundle.url calls
        // For brevity in this example, we're not implementing the actual swizzling
    }
    
    private func restoreBundleURLMethod() {
        // This would restore the original Bundle.url method
        // For brevity in this example, we're not implementing the actual restoration
    }
}

// Mock provider for testing with SVG data
class MockSVGProvider {
    // MIME type for SVG
    private static let svgMimeType = "image/svg+xml"
    
    // Basic valid SVG content
    private static let basicSVGContent = """
    <svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">
        <circle cx="50" cy="50" r="40" stroke="black" stroke-width="2" fill="red" />
    </svg>
    """
    
    // Our mock SVGs dictionary
    private static var mockSVGs: [String: SVGKImage] = [:]
    
    // Register a mock SVG for testing purposes
    static func registerSVGForTests(named name: String) {
        let data = basicSVGContent.data(using: .utf8)!
        if let svgImage = SVGKImage(data: data, mimeType: svgMimeType) {
            mockSVGs[name] = svgImage
        }
    }
    
    // Get a mock SVG by name
    static func getMockSVG(named name: String) -> SVGKImage? {
        return mockSVGs[name]
    }
    
    // Create a SVGKImage from mock data
    static func createMockSVGImage(named name: String) -> SVGKImage? {
        if let existing = mockSVGs[name] {
            return existing
        }
        
        let data = basicSVGContent.data(using: .utf8)!
        return SVGKImage(data: data, mimeType: svgMimeType)
    }
} 