import Foundation
import SwiftUI
import PrivateHomeAI

print("Hello, world! This is a simple test.")

// Simple function to test
func add(_ a: Int, _ b: Int) -> Int {
    return a + b
}

// Test the function
let result = add(2, 3)
print("2 + 3 = \(result)")

if result == 5 {
    print("Test passed!")
} else {
    print("Test failed!")
}

struct SimpleTestView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        ContentView()
            .environmentObject(appState)
    }
}

#if DEBUG
struct SimpleTestView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleTestView()
    }
}
#endif 