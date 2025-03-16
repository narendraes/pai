#!/bin/bash

# Script to run the Private Home AI Demo app

echo "Building and running Private Home AI Demo app..."

# Change to the demo app directory
cd PrivateHomeAIDemo

# Build the app for the simulator
echo "Building the app for the simulator..."
swift build -Xswiftc "-sdk" -Xswiftc "$(xcrun --sdk iphonesimulator --show-sdk-path)" -Xswiftc "-target" -Xswiftc "x86_64-apple-ios15.0-simulator"

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "Build failed. Please check the error messages above."
    exit 1
fi

# Find available simulators
echo "Available iOS Simulators:"
xcrun simctl list devices available | grep "iPhone"

# Get the first available iPhone simulator
SIMULATOR_ID=$(xcrun simctl list devices available | grep "iPhone" | head -1 | sed -E 's/.*\(([A-Z0-9-]+)\).*/\1/')

if [ -z "$SIMULATOR_ID" ]; then
    echo "No available iPhone simulator found."
    exit 1
fi

echo "Using simulator: $SIMULATOR_ID"

# Launch the simulator
echo "Launching simulator..."
xcrun simctl boot "$SIMULATOR_ID" || true

# Install the app
echo "Installing app on simulator..."
xcrun simctl install "$SIMULATOR_ID" .build/debug/PrivateHomeAIDemo

# Launch the app
echo "Launching app on simulator..."
xcrun simctl launch "$SIMULATOR_ID" PrivateHomeAIDemo

echo "Done! The Private Home AI Demo app should now be running in the simulator." 