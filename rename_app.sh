#!/bin/bash

# Nooku App Renaming Script
# Usage: ./rename_app.sh "New App Name"

if [ $# -ne 1 ]; then
    echo "Usage: ./rename_app.sh \"New App Name\""
    echo "Example: ./rename_app.sh \"Nooku\""
    exit 1
fi

NEW_NAME="$1"
INFO_PLIST="CleanNookuApp/CleanNookuApp/Info.plist"

# Check if Info.plist exists
if [ ! -f "$INFO_PLIST" ]; then
    echo "Error: Info.plist not found at $INFO_PLIST"
    exit 1
fi

# Update CFBundleDisplayName in Info.plist
if grep -q "<key>CFBundleDisplayName</key>" "$INFO_PLIST"; then
    # Replace existing display name
    sed -i '' "s/<string>.*<\/string>/<string>$NEW_NAME<\/string>/" "$INFO_PLIST"
else
    # Add display name if it doesn't exist
    sed -i '' "/<key>CFBundleName<\/key>/a\\
    <key>CFBundleDisplayName</key>\\
    <string>$NEW_NAME</string>" "$INFO_PLIST"
fi

echo "✅ App display name updated to \"$NEW_NAME\""
echo "🔄 Build and run the app to see the changes"
echo "📱 The app will appear on your home screen as \"$NEW_NAME\""
