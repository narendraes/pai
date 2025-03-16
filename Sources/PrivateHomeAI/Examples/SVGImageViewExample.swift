import SwiftUI

/// Example view demonstrating how to use SVGImageView in different scenarios
public struct SVGImageViewExample: View {
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Title
                Text("SVG Image Examples")
                    .font(.largeTitle)
                    .padding(.top)
                
                // Basic usage
                VStack {
                    Text("Basic Usage")
                        .font(.headline)
                    
                    SVGImageView(svgName: "example_icon")
                        .frame(width: 100, height: 100)
                        .border(Color.gray, width: 1)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 2)
                
                // With tint color
                VStack {
                    Text("With Tint Color")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        SVGImageView(svgName: "example_icon", tintColor: .red)
                            .frame(width: 60, height: 60)
                        
                        SVGImageView(svgName: "example_icon", tintColor: .blue)
                            .frame(width: 60, height: 60)
                        
                        SVGImageView(svgName: "example_icon", tintColor: .green)
                            .frame(width: 60, height: 60)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 2)
                
                // Error handling
                VStack {
                    Text("Error Handling")
                        .font(.headline)
                    
                    Text("Non-existent SVG with placeholder:")
                        .font(.subheadline)
                        .padding(.top, 4)
                    
                    SVGImageView(
                        svgName: "nonexistent_icon",
                        size: CGSize(width: 100, height: 100),
                        placeholderImage: UIImage(systemName: "exclamationmark.triangle.fill")
                    )
                    .frame(width: 100, height: 100)
                    .border(Color.gray, width: 1)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 2)
                
                // Different sizes
                VStack {
                    Text("Different Sizes")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        SVGImageView(svgName: "example_icon", size: CGSize(width: 40, height: 40))
                            .background(Color.gray.opacity(0.2))
                        
                        SVGImageView(svgName: "example_icon", size: CGSize(width: 80, height: 80))
                            .background(Color.gray.opacity(0.2))
                        
                        SVGImageView(svgName: "example_icon", size: CGSize(width: 120, height: 120))
                            .background(Color.gray.opacity(0.2))
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 2)
                
                // Accessibility example
                VStack {
                    Text("Accessibility")
                        .font(.headline)
                    
                    SVGImageView(svgName: "example_icon", size: CGSize(width: 100, height: 100))
                        .frame(width: 100, height: 100)
                        .accessibilityLabel("Example icon")
                        .accessibilityHint("This is an example SVG icon")
                        .border(Color.gray, width: 1)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 2)
                
                // Performance tips
                VStack(alignment: .leading) {
                    Text("Performance Tips")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• SVGs are cached automatically")
                            .font(.subheadline)
                        
                        Text("• Cache can be cleared when needed")
                            .font(.subheadline)
                        
                        Text("• For large lists, use lazy loading")
                            .font(.subheadline)
                        
                        Text("• Provide reasonable sizes to avoid scaling")
                            .font(.subheadline)
                    }
                    .padding(.top, 4)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 2)
            }
            .padding()
        }
    }
}

// Button to clear SVG cache
struct ClearCacheButton: View {
    @State private var cacheCleared = false
    
    var body: some View {
        Button(action: {
            SVGImageViewModel.clearAllCache()
            cacheCleared = true
            
            // Reset after showing feedback
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                cacheCleared = false
            }
        }) {
            Text(cacheCleared ? "Cache Cleared!" : "Clear SVG Cache")
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(cacheCleared ? Color.green : Color.blue)
                .cornerRadius(8)
        }
        .animation(.easeInOut, value: cacheCleared)
    }
}

// MARK: - SwiftUI Previews
struct SVGImageViewExample_Previews: PreviewProvider {
    static var previews: some View {
        SVGImageViewExample()
    }
} 