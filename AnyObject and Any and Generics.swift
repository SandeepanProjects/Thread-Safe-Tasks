//
//  AnyObject and Any and Generics.swift
//  
//
//  Created by Apple on 08/06/25.
//

import Foundation

Great! Let's break down the **differences between `AnyObject`, `Any`, and Generics** in Swift — three powerful but distinct tools in the type system.

---

## 🧠 Quick Overview

| Concept      | Description                                                 | Supports Value Types | Supports Class Types | Type-safe |
| ------------ | ----------------------------------------------------------- | -------------------- | -------------------- | --------- |
| `AnyObject`  | Protocol for **any class type instance**                    | ❌ No                 | ✅ Yes                | ❌ No      |
| `Any`        | Type-erased container for **any type** (value or reference) | ✅ Yes                | ✅ Yes                | ❌ No      |
| **Generics** | Compile-time flexible, strongly-typed placeholder types     | ✅ Yes                | ✅ Yes                | ✅ Yes     |

---

## 🔷 1. `AnyObject`

### 📌 What it is:

* A protocol representing **any class instance** (reference types only).
* Swift's equivalent of Objective-C's `id` type.

### ✅ Example:

```swift
class Car {}
class Bike {}

let objects: [AnyObject] = [Car(), Bike()]  // ✅ OK

let x: Int = 5
// let y: AnyObject = x  ❌ Error: 'Int' is not a class type
```

---

## 🔶 2. `Any`

### 📌 What it is:

* A type that can represent **any value**, whether it's a struct, enum, class, etc.
* Includes both **reference types** and **value types**.

### ✅ Example:

```swift
let anything: [Any] = [42, "Hello", true, Car()]
```

### ⚠️ Drawback:

* Type information is **erased**, so you must use **type casting**:

```swift
for item in anything {
    if let number = item as? Int {
        print("Int: \(number)")
    }
}
```

---

## 🟢 3. **Generics**

### 📌 What it is:

* A way to write flexible, **type-safe** functions and types.
* **Preserves type information** at compile time (unlike `Any` or `AnyObject`).

### ✅ Example:

```swift
func swapTwoValues<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

var a = 1, b = 2
swapTwoValues(&a, &b)  // Works for any type (Int, String, etc.)
```

---

## 🆚 Key Differences

| Feature               | `AnyObject`                       | `Any`                         | `Generics`                         |
| --------------------- | --------------------------------- | ----------------------------- | ---------------------------------- |
| Value types supported | ❌ No                              | ✅ Yes                         | ✅ Yes                              |
| Type safety           | ❌ Requires casting                | ❌ Requires casting            | ✅ Compile-time safety              |
| Flexibility           | ✅ Flexible for class types        | ✅ Flexible for all types      | ✅ Very flexible, strongly typed    |
| Runtime type info     | ✅ (limited)                       | ✅ (with casting)              | ✅ Full type info at compile time   |
| Performance           | ⚠️ Slower due to casting          | ⚠️ Slower due to type erasure | ✅ Faster due to type knowledge     |
| Typical use cases     | Cocoa APIs, class-only containers | Heterogeneous collections     | Generic algorithms, reusable types |

---

## ✅ Example Use Case Comparison

### 🧺 `Any`

```swift
let mixed: [Any] = [1, "Swift", true]
```

### 🧩 `AnyObject`

```swift
let classOnly: [AnyObject] = [UILabel(), UIButton()]
```

### 🧪 Generics

```swift
func printAll<T>(items: [T]) {
    for item in items {
        print(item)
    }
}

printAll(items: [1, 2, 3])       // [Int]
printAll(items: ["a", "b", "c"]) // [String]
```

---

## 🏁 Summary

* Use **`Any`** when you want to store **any type** but don't need type safety.
* Use **`AnyObject`** when you only care about **class types**.
* Use **Generics** when you want **type-safe, reusable, and flexible** code.

---

Would you like visual examples or a Playground snippet comparing all three in real time?

Perfect! Here's a **Swift Playground-style example** that clearly shows how `Any`, `AnyObject`, and **Generics** behave differently in code.

---

## 🧪 Swift Playground Example: Comparing `Any`, `AnyObject`, and Generics

```swift
import UIKit

// MARK: - Sample Class and Struct
class MyClass: CustomStringConvertible {
    var description: String { "I am a class" }
}

struct MyStruct: CustomStringConvertible {
    var description: String { "I am a struct" }
}

// MARK: - Using `Any`
let mixedArray: [Any] = [42, "Hello", true, MyClass(), MyStruct()]

print("🔷 Any Example:")
for item in mixedArray {
    if let string = item as? String {
        print("String: \(string)")
    } else if let number = item as? Int {
        print("Int: \(number)")
    } else if let obj = item as? CustomStringConvertible {
        print("Object: \(obj)")
    }
}
print("\n")

// MARK: - Using `AnyObject`
let objectArray: [AnyObject] = [UILabel(), UIButton(), MyClass()]  // ✅ Only class instances allowed

print("🔶 AnyObject Example:")
for object in objectArray {
    print("Class type: \(type(of: object))")
}
print("\n")

// let x: AnyObject = 42 ❌ Error – Int is a value type

// MARK: - Using Generics
func describeAll<T: CustomStringConvertible>(items: [T]) {
    print("🟢 Generics Example:")
    for item in items {
        print("Item: \(item)")
    }
    print("\n")
}

describeAll(items: [MyStruct(), MyStruct()])  // ✅ Strongly typed
describeAll(items: [MyClass(), MyClass()])    // ✅ Strongly typed
// describeAll(items: [42, "oops"]) ❌ Compile-time error — type mismatch
```

---

### 🧠 What You'll See in Output:

```
🔷 Any Example:
Int: 42
String: Hello
Object: I am a class
Object: I am a struct

🔶 AnyObject Example:
Class type: UILabel
Class type: UIButton
Class type: MyClass

🟢 Generics Example:
Item: I am a struct

🟢 Generics Example:
Item: I am a class
```

---

## ✅ Key Learnings from the Playground

| Feature           | `Any`                    | `AnyObject`                   | `Generics`                        |
| ----------------- | ------------------------ | ----------------------------- | --------------------------------- |
| Accepts all types | ✅ Yes                    | ❌ No (class types only)       | ✅ Yes (strongly typed)            |
| Type safety       | ❌ Needs casting          | ❌ Needs casting               | ✅ Enforced at compile time        |
| Performance       | ⚠️ Slower (type erasure) | ⚠️ Slower                     | ✅ Fastest (compiler optimized)    |
| Best for          | Mixed-type collections   | UIKit/Foundation class arrays | Reusable logic, custom components |

---
                        
Great question! Avoiding **reference cycles in delegates** is a common and important practice in Swift to prevent **memory leaks**.
                        
                        ---
                        
## 🧠 Why Can Delegates Cause Retain Cycles?
                        
### 🔄 The Problem

* A **class** (e.g., `ViewController`) often sets itself as a **delegate** of another class (e.g., `CustomView`).
* If the **delegate property is a strong reference**, it will strongly hold the `ViewController`.
* But `ViewController` already holds a strong reference to the `CustomView`.
                        
🧨 **Result:** A **retain cycle** occurs, and neither object gets deallocated.
                        
```
ViewController → CustomView
CustomView → ViewController (delegate)
```
                        
---
                        
## ✅ How to Avoid It
                        
### 🟢 Mark the `delegate` as `weak`:
                            
```swift
protocol CustomViewDelegate: AnyObject {
    func didTapButton()
}

class CustomView: UIView {
    weak var delegate: CustomViewDelegate?
    
    func buttonTapped() {
        delegate?.didTapButton()
    }
}
```

> ✅ Using `weak` means `CustomView` does **not increase** the reference count of the delegate, breaking the cycle.

---

### ⚠️ Why Use `AnyObject`?

The protocol must be limited to **class types only** because **only class instances** can be weakly referenced.

```swift
protocol CustomViewDelegate: AnyObject {  // <-- Ensures protocol is class-only
    func didTapButton()
}
```

Without `AnyObject`, you'll get this error:

> ❌ "Protocol ‘CustomViewDelegate’ can only be used as a generic constraint because it has Self or associated type requirements."

---

## 📦 Full Example

```swift
protocol CustomViewDelegate: AnyObject {
    func didTapButton()
}

class CustomView: UIView {
    weak var delegate: CustomViewDelegate?
    
    func simulateTap() {
        delegate?.didTapButton()
    }
}

class ViewController: UIViewController, CustomViewDelegate {
    let customView = CustomView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customView.delegate = self  // ✅ No retain cycle because it's weak
    }
    
    func didTapButton() {
        print("Button was tapped!")
    }
}
```

---

## 🧼 Summary

| Tip                                 | Why?                                  |
| ----------------------------------- | ------------------------------------- |
| Use `weak` for delegate properties  | To avoid retain cycles                |
                    | Constrain protocol with `AnyObject` | To allow weak references (class-only) |
                    | Never use `strong` for delegates    | Leads to retain cycles and leaks      |
                    
                    
