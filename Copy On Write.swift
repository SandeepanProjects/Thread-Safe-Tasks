//
//  Copy On Write.swift
//  
//
//  Created by Apple on 07/06/25.
//

import Foundation

**Copy-on-Write (COW)** is an optimization technique used in Swift to efficiently manage memory when dealing with **value types** like `Array`, `Dictionary`, `Set`, and even custom `struct`s.

---

## 🧠 What is Copy-on-Write?

**Copy-on-Write** means:

> A value type (like a `struct` or `Array`) doesn’t actually get copied when assigned or passed—**until** you try to **mutate** it.

So, multiple variables can **share the same underlying storage** until a mutation happens. When mutation happens, Swift **makes a true copy** of the data to ensure value-type behavior.

---

### 🔁 Why Use It?

* ⚡️ **Performance**: Avoids unnecessary copies of large data.
* ✅ **Preserves value semantics**: Each variable behaves independently when modified.
* 🔒 **Thread safety**: No accidental shared mutation.

---

## 🔬 How It Works: Step-by-Step

### Example with `Array`:

```swift
var a = [1, 2, 3]
var b = a // no copy yet — shares same storage

b.append(4) // now `b` is mutated → real copy happens here!

print(a) // [1, 2, 3]
print(b) // [1, 2, 3, 4]
```

👉 `a` and `b` shared memory **until** `b` was modified. Then Swift **copied** the array to keep them independent.

---

## 🔧 Copy-on-Write in Custom Structs

You can implement COW manually in your own structs using a **class as a reference wrapper**:

```swift
class DataHolder {
    var data: [Int]
    init(data: [Int]) {
        self.data = data
    }
}

struct MyStruct {
    private var holder: DataHolder

    init(data: [Int]) {
        self.holder = DataHolder(data: data)
    }

    var data: [Int] {
        get { holder.data }
        set {
            if !isKnownUniquelyReferenced(&holder) {
                holder = DataHolder(data: newValue) // actual copy
            }
            holder.data = newValue
        }
    }
}
```

* ✅ `isKnownUniquelyReferenced` checks if no one else shares the reference.
* 💡 This pattern allows value semantics with memory-efficient sharing.

---

## ✅ Summary

| Feature           | Description                                          |
| ----------------- | ---------------------------------------------------- |
| **Purpose**       | Improve performance while preserving value semantics |
| **Used by**       | Swift standard types (`Array`, `String`, etc.)       |
| **Triggers copy** | Only when mutation occurs                            |
| **Can be custom** | Yes, via `isKnownUniquelyReferenced()`               |

---
Great! Let’s walk through **Copy-on-Write (COW)** in action with real Swift examples. We’ll use:
                                                
1. ✅ A built-in type like `String` or `Array`
2. 🔧 A custom value type with manual COW implementation
                                            
                                            ---
                                            
## ✅ **COW with Built-in Swift Type (`Array`)**
                                            
Swift arrays use COW by default.
                                            
```swift
var array1 = [1, 2, 3]
var array2 = array1 // No actual copy yet — shared storage
                                            
print("Before mutation")
print("array1:", array1)
print("array2:", array2)
                                            
// Mutate array2
array2.append(4) // Now copy happens
                                            
print("\nAfter mutation")
print("array1:", array1) // [1, 2, 3]
print("array2:", array2) // [1, 2, 3, 4]
```
                                            
✅ `array1` stays the same — **Swift performs a real copy only when array2 is mutated.**
                                            
---
                                            
## 🔧 **Manual Copy-on-Write with a Custom Struct**
                                            
Let’s build a `Document` struct that behaves like a value type but **uses a class for storage** (COW pattern).
                                            
```swift
class DocumentStorage {
    var text: String
    init(text: String) {
        self.text = text
    }
}

struct Document {
    private var storage: DocumentStorage
    
    init(text: String) {
        self.storage = DocumentStorage(text: text)
    }
    
    var text: String {
        get { storage.text }
        set {
            ensureUniqueStorage()
            storage.text = newValue
        }
    }
    
    // Copy-on-Write logic
    private mutating func ensureUniqueStorage() {
        if !isKnownUniquelyReferenced(&storage) {
            storage = DocumentStorage(text: storage.text)
        }
    }
}
```

### 👇 Usage

```swift
var doc1 = Document(text: "Hello")
var doc2 = doc1 // Shares storage

print("Before mutation:")
print("doc1:", doc1.text)
print("doc2:", doc2.text)

doc2.text += " World!" // Mutation → triggers copy

print("\nAfter mutation:")
print("doc1:", doc1.text) // "Hello"
print("doc2:", doc2.text) // "Hello World!"
```

✅ `doc1` and `doc2` share storage *until* `doc2.text` is changed. Then a **copy is made**, keeping value semantics.

---

## 🧠 Behind the Scenes

* `isKnownUniquelyReferenced(&ref)` is a Swift runtime function that checks if the class instance is uniquely referenced.
* It allows Swift to delay copying until it’s **really needed**, saving memory and CPU.
                                                                                
---
                                                                                
## ✅ TL;DR

| Concept        | Description                                      |
| -------------- | ------------------------------------------------ |
| **COW**        | Delays copying until mutation                    |
| **Built-in**   | Used in `Array`, `String`, `Dictionary`, etc.    |
| **Custom**     | Done using `class` + `isKnownUniquelyReferenced` |
| **Efficiency** | Saves resources while acting like a value type   |
                                            
                                            ---
                                            
Let me know if you'd like this implemented in a playground or used in a real app model like a `UserProfile` or `ImageCache`.
Awesome! Let's walk through a **real-world use case** of **Copy-on-Write (COW)** with a custom Swift struct called `UserProfile`, like you'd use in an app.
                                            
---
                                            
## 🧑‍💻 Use Case: `UserProfile` with COW
                                            
Imagine you have a `UserProfile` value type that contains user settings or data you want to copy **only if it changes**, not when passing it around.
                                            
---
                                            
### 🛠 Step 1: Create Reference Storage Class
                                            
```swift
class UserProfileStorage {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}
```

---

### 🧱 Step 2: Define the `UserProfile` Struct with Copy-on-Write Logic

```swift
struct UserProfile {
    private var storage: UserProfileStorage
    
    init(name: String, age: Int) {
        self.storage = UserProfileStorage(name: name, age: age)
    }
    
    var name: String {
        get { storage.name }
        set {
            ensureUniqueStorage()
            storage.name = newValue
        }
    }
    
    var age: Int {
        get { storage.age }
        set {
            ensureUniqueStorage()
            storage.age = newValue
        }
    }
    
    // MARK: - COW logic
    private mutating func ensureUniqueStorage() {
        if !isKnownUniquelyReferenced(&storage) {
            print("🔁 Making a copy of UserProfileStorage")
            storage = UserProfileStorage(name: storage.name, age: storage.age)
        }
    }
}
```

---

### 👨‍🔬 Step 3: Test the COW Behavior

```swift
var profile1 = UserProfile(name: "Alice", age: 30)
var profile2 = profile1 // shared storage at this point

print("Before mutation")
print("profile1.name:", profile1.name)
print("profile2.name:", profile2.name)

profile2.name = "Bob" // triggers copy-on-write

print("\nAfter mutation")
print("profile1.name:", profile1.name) // Alice
print("profile2.name:", profile2.name) // Bob
```

🧪 **Console Output:**

```
Before mutation
profile1.name: Alice
profile2.name: Alice
🔁 Making a copy of UserProfileStorage
After mutation
profile1.name: Alice
profile2.name: Bob
```

---

## ✅ Why This Is Useful in Apps

| Use Case                        | Benefit                            |
| ------------------------------- | ---------------------------------- |
| Shared data across views/models | Efficient until mutation is needed |
| Value semantics + performance   | Best of both worlds                |
| Editable form models            | Copy only when user edits          |
| Background caching or cloning   | Fast sharing of state              |

---

## 📦 Want to Try It?

You can drop this into an Xcode Playground or a SwiftUI preview model for experimentation. If you'd like, I can help convert this into a SwiftUI-compatible observable model or write unit tests around the COW behavior.
                                                                            
Let me know what you'd like next:
                                                                                
* 🔄 A SwiftUI example?
* 🧪 Add tests?
* 🛠 Convert this to handle deep-copy scenarios with nested data?
