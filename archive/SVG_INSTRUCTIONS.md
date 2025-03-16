# SVG Usage Guide for Private Home AI

This guide explains how to use and update SVG files in the Private Home AI app.

## Adding or Updating SVG Files

1. Place your SVG files in the `PrivateHomeAI/SVGs/` directory
2. Make sure the SVG files have the `.svg` extension
3. Follow the SVG 1.1 specification for best compatibility

## SVG File Requirements

- Use simple SVG files with basic shapes and paths
- Keep file sizes small (under 10KB if possible)
- Use a viewBox of "0 0 24 24" for consistent sizing
- Use black (#000000) as the fill color for paths that should be tintable

## Using SVG Files in Code

You can use SVG files in your SwiftUI views in two ways:

### 1. Using SVGImageView directly

```swift
import SwiftUI
import PrivateHomeAI

struct MyView: View {
    var body: some View {
        VStack {
            // Basic usage
            SVGImageView(svgName: "my_icon")
                .frame(width: 100, height: 100)
            
            // With custom size
            SVGImageView(svgName: "my_icon", size: CGSize(width: 50, height: 50))
            
            // With tint color
            SVGImageView(svgName: "my_icon", tintColor: .blue)
        }
    }
}
```

### 2. Using the Image extension

```swift
import SwiftUI
import PrivateHomeAI

struct MyView: View {
    var body: some View {
        VStack {
            // Using the convenience extension
            Image.svg("my_icon", size: CGSize(width: 30, height: 30), tintColor: .red)
        }
    }
}
```

## Running the App with SVG Support

To run the app with SVG support, use the provided script:

```bash
./run_with_svg.sh
```

This script will:
1. Create a temporary Xcode project
2. Copy your SVG files to the appropriate location
3. Build and run the app on the iOS simulator

## Troubleshooting

If your SVG is not rendering correctly:

1. Ensure the SVG file is valid and follows the SVG 1.1 specification
2. Try simplifying complex SVGs
3. Check for unsupported features or elements
4. Verify the file is correctly placed in the SVGs directory
5. Check the console for any error messages related to SVG loading

## Converting App Icon SVG to PNG

If you want to use an SVG as your app icon, you'll need to convert it to PNG files at various sizes:

1. Use a tool like Inkscape, Adobe Illustrator, or an online converter
2. Generate PNGs at the following sizes:
   - 20x20, 29x29, 40x40, 58x58, 60x60, 76x76, 80x80, 87x87, 120x120, 152x152, 167x167, 180x180, 1024x1024
3. Add these PNG files to the AppIcon.appiconset in Xcode

## Additional Resources

- [SVGKit GitHub Repository](https://github.com/SVGKit/SVGKit)
- [SVG 1.1 Specification](https://www.w3.org/TR/SVG11/)
- [Apple Human Interface Guidelines for App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons) 