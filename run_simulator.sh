#!/bin/bash

# Script to run the PrivateHomeAI app in the iOS simulator

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Private Home AI Simulator Runner ===${NC}"
echo -e "${BLUE}This script will build and run the app in the iOS simulator${NC}"

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: Xcode is not installed or not in PATH${NC}"
    echo "Please install Xcode from the App Store or make sure it's in your PATH"
    exit 1
fi

# Get available simulators
echo -e "${BLUE}Fetching available simulators...${NC}"
SIMULATORS=$(xcrun simctl list devices available | grep -v "unavailable" | grep "iPhone")

# Check if any simulators are available
if [ -z "$SIMULATORS" ]; then
    echo -e "${RED}Error: No iPhone simulators found${NC}"
    echo "Please create an iPhone simulator in Xcode before running this script"
    exit 1
fi

# Display available simulators
echo -e "${GREEN}Available iPhone simulators:${NC}"
echo "$SIMULATORS" | grep -v "unavailable" | awk -F '[()]' '{print $1}' | awk '{$1=$1};1' | nl -w2 -s") "

# Ask user to select a simulator
echo -e "${BLUE}Enter the number of the simulator you want to use:${NC}"
read -r SIMULATOR_NUM

# Get the selected simulator name
SIMULATOR_NAME=$(echo "$SIMULATORS" | awk -F '[()]' '{print $1}' | awk '{$1=$1};1' | sed -n "${SIMULATOR_NUM}p")
SIMULATOR_UDID=$(echo "$SIMULATORS" | sed -n "${SIMULATOR_NUM}p" | awk -F '[()]' '{print $2}')

if [ -z "$SIMULATOR_NAME" ]; then
    echo -e "${RED}Error: Invalid simulator selection${NC}"
    exit 1
fi

echo -e "${GREEN}Selected simulator: $SIMULATOR_NAME ($SIMULATOR_UDID)${NC}"

# Build the app
echo -e "${BLUE}Building the app...${NC}"
xcodebuild -project PrivateHomeAI.xcodeproj -scheme PrivateHomeAI -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" build

# Check if build was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Build failed${NC}"
    exit 1
fi

# Run the app in the simulator
echo -e "${BLUE}Launching simulator...${NC}"
xcrun simctl boot "$SIMULATOR_UDID" 2>/dev/null || true
echo -e "${BLUE}Installing and launching the app...${NC}"
xcrun simctl install "$SIMULATOR_UDID" build/Debug-iphonesimulator/PrivateHomeAI.app
xcrun simctl launch "$SIMULATOR_UDID" com.privatehomeai.app

echo -e "${GREEN}App launched successfully!${NC}"
echo -e "${BLUE}You can now interact with the Private Home AI app in the simulator${NC}" 