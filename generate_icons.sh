#!/bin/bash
ICON_DIR="CleanNookuApp/CleanNookuApp/Assets.xcassets/AppIcon.appiconset"
ORIGINAL_ICON="$1"
if [ -z "$ORIGINAL_ICON" ]; then echo "Usage: $0 path/to/original_icon.png"; exit 1; fi
if [ ! -f "$ORIGINAL_ICON" ]; then echo "Error: Icon file not found: $ORIGINAL_ICON"; exit 1; fi
sips -z 40 40 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_20pt@2x.png"
sips -z 60 60 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_20pt@3x.png"
sips -z 58 58 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_29pt@2x.png"
sips -z 1024 1024 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_1024pt.png"
echo "Icons generated successfully!"
