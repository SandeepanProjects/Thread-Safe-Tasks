//
//  Swift 6.swift
//  
//
//  Created by Apple on 09/06/25.
//

import Foundation

Here are some of the **new features in Swift 6**, along with **code examples** to help you understand how they work in practice:

---

## 🔒 1. **Compile-Time Data Race Detection**

Swift 6 introduces **compile-time checks** to help detect potential data races in concurrent code.

### 🧠 Example (Before Swift 6 – unsafe):

```swift
class Counter {
    var value = 0

    func increment() {
        DispatchQueue.global().async {
            self.value += 1 // ❗ Potential data race
        }
    }
}
```

### ✅ Swift 6 Enforces Safety:

You now need to use **actor** or **Sendable** types:

```swift
actor SafeCounter {
    var value = 0

    func increment() {
        value += 1
    }
}
```

---

## 📛 2. **Typed Throws**

Specify **which error types** a function can throw, making error handling more predictable and clear.

### ✅ Example:

```swift
enum FileError: Error {
    case notFound
    case unreadable
}

func readFile(name: String) throws(FileError) -> String {
    throw FileError.notFound
}

do {
    let content = try readFile(name: "data.txt")
} catch FileError.notFound {
    print("File not found.")
}
```

---

## 🔒 3. **Noncopyable Types**

You can now define **noncopyable structs**, which prevents bugs caused by unintended copying of resources.

### 🧱 Example:

```swift
@_noCopyable
struct FileHandle {
    var fileDescriptor: Int
}

// Using it
let handle1 = FileHandle(fileDescriptor: 3)
// let handle2 = handle1 // ❌ Error: Cannot copy
```

---

## 🛠 4. **Swift Assist (AI-Powered Code Helper in Xcode 16)**

While not a language feature per se, **Swift Assist** helps with:

* Generating code snippets
* Completing boilerplate
* Writing tests

> It's similar to GitHub Copilot but deeply integrated with Apple SDKs and Xcode.

---

## 🧪 5. **Improved Testing with Tagged Tests**

Swift now supports **tagged and parameterized tests**, useful for running test subsets.

### ✅ Example:

```swift
@available(iOS 17, *)
@Tag("performance")
func testImageLoadingPerformance() {
    // Performance test logic
}
```

---

## ➕ 6. **Isolation Regions (Concurrency Upgrade)**

Allows declaring **safe concurrent regions** without full actor isolation.

### 🧠 Example:

```swift
@Region(isolated: true)
func updateUI() {
    // Compiler guarantees no data race here
}
```

---

Would you like to try writing a small Swift 6 project using these features? Or need help running it in Xcode 16?

Great! Let's create a **small Swift 6 project** that demonstrates a few of the new features in action:

---

## ✅ **Project Name**: `SecureCounterApp`

### 🔍 Features we’ll include:

1. `actor` for safe concurrency (compile-time data race detection)
2. `typed throws` for precise error handling
3. `noncopyable struct` for resource safety
4. A test function using tags

---

## 📂 Step-by-Step Code Structure

### 1. **Create the Project**

In **Xcode 16**:

* Open Xcode → `File > New > Project`
* Choose `App` → Product Name: `SecureCounterApp`
* Language: Swift
* Interface: SwiftUI or UIKit (either works; we’ll use SwiftUI for simplicity)

---

### 2. **Model: Noncopyable FileHandle**

```swift
@_noCopyable
struct FileHandle {
    let descriptor: Int

    init(descriptor: Int) {
        self.descriptor = descriptor
    }

    func read() -> String {
        return "Simulated file content from descriptor \(descriptor)"
    }
}
```

---

### 3. **Actor-Based Counter**

```swift
actor SafeCounter {
    private var value = 0

    func increment() {
        value += 1
    }

    func getValue() -> Int {
        return value
    }
}
```

---

### 4. **Typed Throws Function**

```swift
enum CounterError: Error {
    case thresholdExceeded
}

func validateCount(_ count: Int) throws(CounterError) {
    if count > 10 {
        throw CounterError.thresholdExceeded
    }
}
```

---

### 5. **SwiftUI UI + Test Call**

```swift
import SwiftUI

@main
struct SecureCounterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var count = 0
    let counter = SafeCounter()

    var body: some View {
        VStack {
            Text("Count: \(count)")
                .padding()

            Button("Increment") {
                Task {
                    await counter.increment()
                    let newCount = await counter.getValue()
                    do {
                        try validateCount(newCount)
                        count = newCount
                    } catch CounterError.thresholdExceeded {
                        print("Counter exceeded safe limit.")
                    }
                }
            }
        }
        .padding()
    }
}
```

---

### 6. **Tagged Test Example (Optional)**

If you add a test target:

```swift
import XCTest

final class CounterTests: XCTestCase {

    @Tag("performance")
    func testCounterPerformance() async throws {
        let counter = SafeCounter()
        for _ in 0..<1000 {
            await counter.increment()
        }
        let finalValue = await counter.getValue()
        XCTAssertEqual(finalValue, 1000)
    }
}
```

---

## 🚀 Ready to Run

To run the app:

1. Open the project in **Xcode 16**
2. Run it on a simulator or device
3. Press the **Increment** button to see safe counting with typed error handling

---
