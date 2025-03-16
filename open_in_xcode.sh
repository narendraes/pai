#!/bin/bash

# Set error handling
set -e

echo "🚀 Opening PrivateHomeAI in Xcode..."

# Check if Xcode is installed
if ! command -v xcrun &> /dev/null; then
    echo "❌ Error: Xcode command line tools not found. Please install Xcode."
    exit 1
fi

# Open the project in Xcode
xed .

echo "✅ Project opened in Xcode!"
echo ""
echo "To run the app in the simulator:"
echo "1. Select the PrivateHomeAI scheme from the scheme selector (top left)"
echo "2. Select an iOS Simulator from the device menu (next to the scheme selector)"
echo "3. Click the Run button (▶) or press Cmd+R"
echo ""
echo "If you encounter build errors:"
echo "1. Go to the Project Navigator (left sidebar)"
echo "2. Select the PrivateHomeAI project"
echo "3. Go to the 'Build Settings' tab"
echo "4. Make sure 'Supported Platforms' is set to iOS"
echo "5. Make sure 'Base SDK' is set to 'iOS'"
echo ""
echo "For more help, refer to the Cursor extensions for iOS development." 