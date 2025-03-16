# Image Resources

This directory contains all app images. 

## Supported Formats

- JPEG (.jpg, .jpeg)
- PNG (.png)

## Image Organization

Place your images in this directory using the following structure:

```
Resources/
└── Images/
    ├── app_logo.png
    ├── backgrounds/
    │   ├── home_bg.jpg
    │   └── settings_bg.jpg
    └── icons/
        ├── home.png
        ├── settings.png
        └── profile.png
```

## Using Images in SwiftUI

### Basic Usage

```swift
// Basic image display
ImageView(imageName: "app_logo")
```

### With Size

```swift
// With specific size
ImageView(
    imageName: "app_logo", 
    size: CGSize(width: 100, height: 100)
)
```

### With Content Mode

```swift
// Different aspect ratios
ImageView(
    imageName: "backgrounds/home_bg", 
    contentMode: .fill
)
```

### With Tint Color

```swift
// With tint color (for template images)
ImageView(
    imageName: "icons/settings", 
    tintColor: .blue
)
```

## Best Practices

1. **Naming Convention**: Use lowercase names with underscores for word separation
2. **Image Sizes**: Provide images at 1x, 2x, and 3x resolutions when possible
3. **Optimization**: Compress images to reduce app size
4. **File Organization**: Group related images in subdirectories 