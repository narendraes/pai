#!/bin/bash

# Set error handling
set -e

echo "📱 Building and running PrivateHomeAI in iOS Simulator..."

# Check if Xcode is installed
if ! command -v xcrun &> /dev/null; then
    echo "❌ Error: Xcode command line tools not found. Please install Xcode."
    exit 1
fi

# Build for iOS simulator
echo "🔨 Building for iOS simulator..."
swift build -Xswiftc "-sdk" -Xswiftc "$(xcrun --sdk iphonesimulator --show-sdk-path)" -Xswiftc "-target" -Xswiftc "x86_64-apple-ios15.0-simulator"

# Check if a simulator is running
if ! xcrun simctl list devices booted | grep -q "Booted"; then
    echo "🚀 No simulator running. Starting iPhone simulator..."
    xcrun simctl boot "iPhone 14" 2>/dev/null || xcrun simctl boot "iPhone 13" 2>/dev/null || xcrun simctl boot "$(xcrun simctl list devices available | grep "iPhone" | head -1 | sed -E 's/.*\(([A-Z0-9-]+)\).*/\1/')"
    open -a Simulator
    sleep 5
fi

# Install the app to the simulator
echo "📲 Installing app to simulator..."
xcrun simctl install booted .build/debug/PrivateHomeAI.app || {
    echo "⚠️ App installation failed. Trying to open project in Xcode instead..."
    xed .
    echo "Please run the app from Xcode using the Run button."
    exit 1
}

# Launch the app
echo "🚀 Launching app in simulator..."
xcrun simctl launch booted com.example.PrivateHomeAI || {
    echo "⚠️ App launch failed. Please check the bundle identifier and try again."
    echo "Opening project in Xcode for debugging..."
    xed .
    exit 1
}

echo "✅ App is now running in the simulator!" 