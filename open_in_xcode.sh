#!/bin/bash

# Script to open the Private Home AI package in Xcode

echo "Opening Private Home AI in Xcode..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "Error: Xcode is not installed or not in PATH"
    echo "Please install Xcode from the App Store or make sure it's in your PATH"
    exit 1
fi

# Open the package in Xcode
open -a Xcode .

echo "Xcode should now be opening the Private Home AI package."
echo "To run the app in the simulator, please follow the instructions in SIMULATOR_INSTRUCTIONS.md" 