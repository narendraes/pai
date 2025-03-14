import Foundation

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