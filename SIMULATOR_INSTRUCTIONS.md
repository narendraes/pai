# Running Private Home AI in the iOS Simulator

Follow these steps to run the Private Home AI app in the iOS Simulator:

## Option 1: Using Xcode

1. Open Xcode and create a new iOS App project
   - Choose "App" as the template
   - Name it "PrivateHomeAIDemo"
   - Select "SwiftUI" for the interface
   - Select "Swift" for the language
   - Choose iOS 15.0 as the minimum deployment target

2. Add the Private Home AI package as a dependency
   - In Xcode, go to File > Add Packages...
   - Click on "Add Local..."
   - Select the root folder of the Private Home AI package (where Package.swift is located)
   - Click "Add Package"

3. Update the main app file
   - Replace the content of `PrivateHomeAIDemoApp.swift` with:

```swift
import SwiftUI
import PrivateHomeAI

@main
struct PrivateHomeAIDemoApp: App {
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
                .alert("Security Warning", isPresented: $appState.showJailbreakAlert) {
                    Button("Exit", role: .destructive) {
                        exit(0)
                    }
                } message: {
                    Text("This device appears to be jailbroken. For security reasons, this app cannot run on jailbroken devices.")
                }
        }
    }
}
```

4. Delete the default ContentView.swift file that Xcode created

5. Run the app
   - Select an iOS Simulator from the device menu
   - Click the Run button (▶) or press Cmd+R

## Option 2: Using Swift Package Manager

1. Create a new directory for your app
   ```bash
   mkdir PrivateHomeAIDemo
   cd PrivateHomeAIDemo
   ```

2. Create a Package.swift file
   ```bash
   cat > Package.swift << EOF
   // swift-tools-version:5.7
   import PackageDescription

   let package = Package(
       name: "PrivateHomeAIDemo",
       platforms: [
           .iOS(.v15)
       ],
       dependencies: [
           .package(path: "../"),
       ],
       targets: [
           .executableTarget(
               name: "PrivateHomeAIDemo",
               dependencies: [
                   .product(name: "PrivateHomeAI", package: "PrivateHomeAI")
               ]),
       ]
   )
   EOF
   ```

3. Create the app source file
   ```bash
   mkdir -p Sources/PrivateHomeAIDemo
   cat > Sources/PrivateHomeAIDemo/main.swift << EOF
   import SwiftUI
   import PrivateHomeAI

   @main
   struct PrivateHomeAIDemoApp: App {
       @StateObject private var appState = AppState()
       
       var body: some Scene {
           WindowGroup {
               ContentView()
                   .environmentObject(appState)
           }
       }
   }
   EOF
   ```

4. Build the app for the simulator
   ```bash
   swift build -Xswiftc "-sdk" -Xswiftc "$(xcrun --sdk iphonesimulator --show-sdk-path)" -Xswiftc "-target" -Xswiftc "x86_64-apple-ios15.0-simulator"
   ```

5. Run the app in the simulator
   ```bash
   xcrun simctl boot "iPhone 14"
   xcrun simctl install booted .build/debug/PrivateHomeAIDemo
   xcrun simctl launch booted com.example.PrivateHomeAIDemo
   ```

## Troubleshooting

If you encounter any issues:

1. Make sure you have the latest version of Xcode installed
2. Verify that the Private Home AI package builds successfully on its own
3. Check that all dependencies are properly resolved
4. Try cleaning the build folder and rebuilding
5. Ensure the simulator is running the correct iOS version (15.0 or later) 