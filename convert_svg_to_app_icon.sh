#!/bin/bash

# Script to convert SVG to iOS app icon PNG files
# This script requires ImageMagick to be installed

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is not installed"
    echo "Please install ImageMagick first:"
    echo "  macOS: brew install imagemagick"
    echo "  Linux: sudo apt-get install imagemagick"
    exit 1
fi

# Check if SVG file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <svg_file>"
    echo "Example: $0 my_icon.svg"
    exit 1
fi

SVG_FILE="$1"

# Check if the SVG file exists
if [ ! -f "$SVG_FILE" ]; then
    echo "Error: SVG file '$SVG_FILE' not found"
    exit 1
fi

# Create AppIcon.appiconset directory if it doesn't exist
ICON_DIR="PrivateHomeAI/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$ICON_DIR"

echo "Converting SVG to PNG for iOS app icons..."

# Convert SVG to PNG for each size
echo "Creating icon_20pt_2x.png (40x40)..."
convert -background none -density 1200 -resize 40x40 "$SVG_FILE" "$ICON_DIR/icon_20pt_2x.png"

echo "Creating icon_20pt_3x.png (60x60)..."
convert -background none -density 1200 -resize 60x60 "$SVG_FILE" "$ICON_DIR/icon_20pt_3x.png"

echo "Creating icon_29pt_2x.png (58x58)..."
convert -background none -density 1200 -resize 58x58 "$SVG_FILE" "$ICON_DIR/icon_29pt_2x.png"

echo "Creating icon_29pt_3x.png (87x87)..."
convert -background none -density 1200 -resize 87x87 "$SVG_FILE" "$ICON_DIR/icon_29pt_3x.png"

echo "Creating icon_40pt_2x.png (80x80)..."
convert -background none -density 1200 -resize 80x80 "$SVG_FILE" "$ICON_DIR/icon_40pt_2x.png"

echo "Creating icon_40pt_3x.png (120x120)..."
convert -background none -density 1200 -resize 120x120 "$SVG_FILE" "$ICON_DIR/icon_40pt_3x.png"

echo "Creating icon_60pt_2x.png (120x120)..."
convert -background none -density 1200 -resize 120x120 "$SVG_FILE" "$ICON_DIR/icon_60pt_2x.png"

echo "Creating icon_60pt_3x.png (180x180)..."
convert -background none -density 1200 -resize 180x180 "$SVG_FILE" "$ICON_DIR/icon_60pt_3x.png"

echo "Creating icon_76pt.png (76x76)..."
convert -background none -density 1200 -resize 76x76 "$SVG_FILE" "$ICON_DIR/icon_76pt.png"

echo "Creating icon_76pt_2x.png (152x152)..."
convert -background none -density 1200 -resize 152x152 "$SVG_FILE" "$ICON_DIR/icon_76pt_2x.png"

echo "Creating icon_83.5pt_2x.png (167x167)..."
convert -background none -density 1200 -resize 167x167 "$SVG_FILE" "$ICON_DIR/icon_83.5pt_2x.png"

echo "Creating icon_1024pt.png (1024x1024)..."
convert -background none -density 1200 -resize 1024x1024 "$SVG_FILE" "$ICON_DIR/icon_1024pt.png"

# Create Contents.json file
cat > "$ICON_DIR/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "icon_20pt_2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "icon_20pt_3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "icon_29pt_2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "icon_29pt_3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "icon_40pt_2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "icon_40pt_3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "icon_60pt_2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "icon_60pt_3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "icon_20pt_2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "icon_29pt_2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "icon_40pt_2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "icon_76pt.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76"
    },
    {
      "filename" : "icon_76pt_2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "icon_83.5pt_2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "filename" : "icon_1024pt.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "Done! App icon PNG files have been created in $ICON_DIR"
echo "You can now open the project in Xcode to see the new app icon." 