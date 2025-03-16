# SVGImageView

A high-performance SwiftUI component for rendering SVG images with proper error handling, caching, and accessibility support.

## Features

- Renders SVG files from app bundle
- Supports tint color for monochrome SVGs
- Handles missing or invalid SVGs gracefully
- Implements memory-efficient caching
- Provides accessibility support
- Supports custom placeholder images
- Thread-safe and memory-leak free

## Usage

### Basic Usage

```swift
SVGImageView(svgName: "my_icon")
    .frame(width: 100, height: 100)
```

### With Tint Color

```swift
SVGImageView(svgName: "my_icon", tintColor: .blue)
    .frame(width: 100, height: 100)
```

### With Size Specification

```swift
SVGImageView(svgName: "my_icon", size: CGSize(width: 100, height: 100))
```

### With Error Handling

```swift
SVGImageView(
    svgName: "my_icon", 
    size: CGSize(width: 100, height: 100),
    placeholderImage: UIImage(systemName: "exclamationmark.triangle.fill")
)
```

### With Accessibility

```swift
SVGImageView(svgName: "my_icon")
    .frame(width: 100, height: 100)
    .accessibilityLabel("My icon")
    .accessibilityHint("This icon represents a camera")
```

## SVG File Organization

SVG files should be organized in one of these locations:

1. In a `SVGs` directory within your app bundle
2. In the root of your app bundle

The component will first search in `SVGs/your_file.svg` and then fallback to `your_file.svg` in the root.

## Performance Considerations

### Caching

SVGImageView automatically caches loaded SVGs to optimize performance. The cache is implemented as a static NSCache with a size limit of 10MB.

To manually clear the cache:

```swift
// Clear cache for a specific SVG
SVGImageViewModel.clearCache(for: "my_icon")

// Clear entire cache
SVGImageViewModel.clearAllCache()
```

### File Size

SVG files should be optimized for minimal file size:

- Remove unnecessary metadata
- Simplify paths when possible
- Consider using tools like SVGO for optimization

### Memory Usage

The component estimates memory usage to properly manage cache. For very large SVGs, consider:

- Breaking into smaller components
- Using rasterized images for very complex SVGs
- Testing performance with large datasets

## Error Handling

The component handles various error cases gracefully:

- **File Not Found**: When the SVG file doesn't exist
- **Loading Failed**: When the SVG format is invalid
- **Rendering Failed**: When the SVG can't be rendered

All errors are properly logged in debug mode to assist with troubleshooting.

## Architecture

The component follows MVVM architecture:

- **View**: `SVGImageView` - SwiftUI component that displays the SVG
- **ViewModel**: `SVGImageViewModel` - Handles loading, caching and state management
- **Model**: `SVGKImage` from SVGKit framework

## Testing

Unit tests are available in `SVGImageViewTests.swift` covering:

- SVG loading
- Error handling
- Caching behavior
- View creation

## Requirements

- iOS 15.0+
- SVGKit framework

## Security Considerations

SVG files can contain scripts or external references. For maximum security:

- Validate all SVGs before including in your app bundle
- Consider using a tool to sanitize SVGs
- Do not load untrusted SVGs from external sources without sanitization

## Examples

See `SVGImageViewExample.swift` for full usage examples of all features. 