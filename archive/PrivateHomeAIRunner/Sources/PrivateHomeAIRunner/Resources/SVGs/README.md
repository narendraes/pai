# SVG Files for Private Home AI

This directory contains SVG files used in the Private Home AI app.

## Adding SVG Files

1. Place your SVG files in this directory
2. Make sure the SVG files have the `.svg` extension
3. When building the app, these files will be included in the app bundle

## Using SVG Files in the App

You can use the SVG files in your SwiftUI views using the `SVGImageView` component:

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
            
            // Using the convenience extension
            Image.svg("my_icon", size: CGSize(width: 30, height: 30), tintColor: .red)
        }
    }
}
```

## Supported SVG Features

The SVG rendering is powered by the [SVGKit](https://github.com/SVGKit/SVGKit) library, which supports most SVG 1.1 features.

## Troubleshooting

If your SVG is not rendering correctly:

1. Ensure the SVG file is valid and follows the SVG 1.1 specification
2. Try simplifying complex SVGs
3. Check for unsupported features or elements
4. Verify the file is correctly placed in this directory 