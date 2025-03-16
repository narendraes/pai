#!/bin/bash

# Script to build and run Nooku on iOS Simulator

echo "Building and running Nooku on iOS Simulator..."

# Create a proper Xcode project with a target
echo "Creating Xcode project with target..."

# Create a temporary directory for the project and clean it if it exists
TEMP_DIR="NookuRunner"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR/Sources/NookuRunner"

# Create the Swift files
cat > "$TEMP_DIR/Sources/NookuRunner/NookuRunnerApp.swift" << EOF
import SwiftUI
import Nooku

@main
struct NookuRunnerApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    // Check for jailbreak
                    if JailbreakDetectionService.shared.isJailbroken() {
                        appState.showJailbreakAlert = true
                    }
                }
                .alert("Security Warning", isPresented: \$appState.showJailbreakAlert) {
                    Button("Exit", role: .destructive) {
                        exit(0)
                    }
                } message: {
                    Text("This device appears to be jailbroken. For security reasons, this app cannot run on jailbroken devices.")
                }
        }
    }
}
EOF

# Create a new Xcode project using Swift Package Manager
echo "Creating Swift package for the runner app..."
cat > "$TEMP_DIR/Package.swift" << EOF
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "NookuRunner",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    dependencies: [
        .package(path: "../"),
    ],
    targets: [
        .executableTarget(
            name: "NookuRunner",
            dependencies: [
                .product(name: "Nooku", package: "pai")
            ]
        ),
    ]
)
EOF

# Create Info.plist file directly in the project directory
mkdir -p "$TEMP_DIR/NookuRunner.xcodeproj"
cat > "$TEMP_DIR/NookuRunner.xcodeproj/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>NookuRunner</string>
	<key>CFBundleIdentifier</key>
	<string>com.nooku.home.runner</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>NookuRunner</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>NSFaceIDUsageDescription</key>
	<string>We use Face ID to securely authenticate you to the app.</string>
	<key>UIApplicationSceneManifest</key>
	<dict>
		<key>UIApplicationSupportsMultipleScenes</key>
		<false/>
	</dict>
	<key>UILaunchScreen</key>
	<dict/>
	<key>UIRequiredDeviceCapabilities</key>
	<array>
		<string>armv7</string>
	</array>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
</dict>
</plist>
EOF

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

# Build the app for the simulator
echo "Building the app for the simulator..."
(cd "$TEMP_DIR" && swift build -Xswiftc "-sdk" -Xswiftc "$(xcrun --sdk iphonesimulator --show-sdk-path)" -Xswiftc "-target" -Xswiftc "x86_64-apple-ios15.0-simulator")

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "Build failed. Please check the error messages above."
    exit 1
fi

# Launch the simulator
echo "Launching simulator..."
xcrun simctl boot "$SIMULATOR_ID" || true

# Install the app
echo "Installing app on simulator..."
xcrun simctl install "$SIMULATOR_ID" "$TEMP_DIR/.build/debug/NookuRunner"

# Launch the app
echo "Launching app on simulator..."
xcrun simctl launch "$SIMULATOR_ID" "com.nooku.home.runner"

echo "Done! The Nooku app should now be running in the simulator." 