#!/bin/bash

# Directory where the app icons will be saved
ICON_DIR="CleanNookuApp/CleanNookuApp/Assets.xcassets/AppIcon.appiconset"

# Get the original icon from command line argument
ORIGINAL_ICON="$1"

# Check if the original icon is provided
if [ -z "$ORIGINAL_ICON" ]; then
    echo "Usage: $0 path/to/original_icon.png"
    exit 1
fi

# Check if the original icon file exists
if [ ! -f "$ORIGINAL_ICON" ]; then
    echo "Error: Icon file not found: $ORIGINAL_ICON"
    exit 1
fi

# Create the directory if it doesn't exist
mkdir -p "$ICON_DIR"

# Generate all required icon sizes
echo "Generating app icons..."

# iPhone icons
sips -z 40 40 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_20pt@2x.png"
sips -z 60 60 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_20pt@3x.png"
sips -z 29 29 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_29pt.png"
sips -z 58 58 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_29pt@2x.png"
sips -z 87 87 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_29pt@3x.png"
sips -z 40 40 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_40pt.png"
sips -z 80 80 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_40pt@2x.png"
sips -z 120 120 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_40pt@3x.png"
sips -z 120 120 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_60pt@2x.png"
sips -z 180 180 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_60pt@3x.png"

# iPad icons
sips -z 20 20 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_20pt.png"
sips -z 76 76 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_76pt.png"
sips -z 152 152 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_76pt@2x.png"
sips -z 167 167 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_83.5pt@2x.png"

# App Store icon
sips -z 1024 1024 "$ORIGINAL_ICON" --out "$ICON_DIR/Icon.png"

echo "Icons generated successfully!"
