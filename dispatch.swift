//
//  dispatch.swift
//  
//
//  Created by Apple on 08/06/25.
//

import Foundation
Great question! Understanding **dynamic vs. static dispatch** is key to mastering how Swift resolves method calls — especially when it comes to performance and polymorphism.

---

## 🧠 What Is Dispatch?

**Dispatch** refers to how a programming language decides **which method implementation to call** at **runtime or compile time**.

---

## 📌 1. **Static Dispatch (Compile-Time)**

### 🧾 What is it?

* The method to be called is **determined at compile time**.
* The compiler **knows the exact type** and can call the method **directly**, often inlined.
* **Faster** than dynamic dispatch.

### ✅ Examples:

* **Structs, enums**, and **final classes/methods** in Swift.
* **Protocol extensions** when not using dynamic features.

```swift
struct Dog {
    func speak() {
        print("Bark")
    }
}

let dog = Dog()
dog.speak()  // 🔧 Static dispatch — compiler knows what to call
```

---

## 📌 2. **Dynamic Dispatch (Runtime)**

### 🧾 What is it?

* The method to call is **determined at runtime**, based on the **actual object type**.
* Uses **virtual tables (v-tables)** or **Objective-C runtime (objc\_msgSend)**.
* Supports **polymorphism** and **method overriding**.

### ✅ Examples:

* **Class inheritance**
* **Overridable methods**
* **Objective-C interop (`@objc`)**
* **Protocols with associated types or existential types**

```swift
class Animal {
    func speak() {
        print("Some sound")
    }
}

class Cat: Animal {
    override func speak() {
        print("Meow")
    }
}

let animal: Animal = Cat()
animal.speak()  // 🔄 Dynamic dispatch — resolves to Cat's speak() at runtime
```

---

## 🔄 Comparison Table

| Feature               | Static Dispatch                  | Dynamic Dispatch                             |
| --------------------- | -------------------------------- | -------------------------------------------- |
| Timing                | Compile time                     | Runtime                                      |
| Performance           | Faster                           | Slightly slower                              |
| Used In               | Structs, final methods, generics | Classes with inheritance, `@objc`, protocols |
| Polymorphism          | ❌ Not supported                  | ✅ Supported                                  |
| Inlining Optimization | ✅ Yes                            | ❌ No                                         |

---

## ⚠️ Important Swift Behavior

### 1. **Final methods** use static dispatch:

```swift
final class Dog {
    final func bark() {
        print("Woof")
    }
}
```

### 2. **@objc methods** use Objective-C dynamic dispatch:

```swift
@objc class MyClass: NSObject {
    @objc func doSomething() {
        print("Action!")
    }
}
```

### 3. **Protocol methods**:

* If using **existential types** (`someProtocol as Protocol`), Swift uses **dynamic dispatch**.
* If using **generics**, Swift can use **static dispatch**.

```swift
protocol Runner {
    func run()
}

struct Human: Runner {
    func run() { print("Running") }
}

func race<T: Runner>(_ participant: T) {
    participant.run()  // Static dispatch
}

func dynamicRace(_ participant: Runner) {
    participant.run()  // Dynamic dispatch
}
```

---

## ✅ Summary

| Use Case                  | Dispatch Type | Notes                         |
| ------------------------- | ------------- | ----------------------------- |
| Struct methods            | Static        | Compile-time determined       |
| Class methods (non-final) | Dynamic       | Runtime lookup using v-tables |
| Final methods             | Static        | Cannot be overridden          |
| `@objc` methods           | Dynamic       | Uses Objective-C runtime      |
| Protocols (generics)      | Static        | Fast and inlined              |
| Protocols (existentials)  | Dynamic       | Enables polymorphism          |

---

Would you like a visualization of how v-tables or method dispatch look in memory?

Great! Let's walk through a **visual explanation** of how **dynamic dispatch (via v-tables)** and **static dispatch** work behind the scenes in Swift.

---

## 🧠 Dispatch Mechanisms Visualization

---

## 📌 1. **Static Dispatch (Compile-Time Direct Call)**

When Swift can determine the exact function to call at **compile time**, it directly inserts a **function pointer** (or even inlines the code). This is fast and predictable.

### ✅ Example

```swift
struct Dog {
    func speak() {
        print("Bark!")
    }
}

let myDog = Dog()
myDog.speak()
```

### 🧩 Behind the Scenes

```
Compile-Time:
-----------------------------
CALL → Dog.speak()
        ↓
Machine Code: print("Bark!")
```

* No lookup needed.
* Often gets **inlined** (copied directly into the calling code).
* Very fast.

---

## 📌 2. **Dynamic Dispatch (Using v-table)**

In class inheritance, method resolution happens at **runtime** using a **v-table** (virtual method table), which stores pointers to actual method implementations.

### ✅ Example

```swift
class Animal {
    func speak() {
        print("Some sound")
    }
}

class Cat: Animal {
    override func speak() {
        print("Meow")
    }
}

let animal: Animal = Cat()
animal.speak()
```

### 🧩 Behind the Scenes

```
Runtime:
-----------------------------
animal.speak()
        ↓
Look up v-table for Cat
        ↓
CALL → Cat.speak()
        ↓
Machine Code: print("Meow")
```

### 📊 Simplified V-Table Representation

| Method Name | Animal v-table | Cat v-table   |
| ----------- | -------------- | ------------- |
| `speak()`   | Animal.speak   | **Cat.speak** |

* When you call `animal.speak()`, it checks the **actual object type** (`Cat`) and looks up the method in the **v-table**.
* Allows **method overriding and polymorphism**.

---

## 🧪 Bonus: `@objc` Dynamic Dispatch (Objective-C runtime)

If you mark a class or method with `@objc`, Swift uses the **Objective-C runtime** to call the method using `objc_msgSend`.

```swift
@objc class ObjClass: NSObject {
    @objc func hello() {
        print("Hello from Objective-C runtime")
    }
}
```

### 🔄 Behind the Scenes:

```
objc_msgSend(obj, selector("hello"))
→ Finds implementation → Calls it
```

* Flexible (e.g., used in `#selector` or KVO)
* But slower than v-table or static calls

---

## ⚠️ Performance Summary

| Dispatch Type     | Speed      | Polymorphism | Use Case                         |
| ----------------- | ---------- | ------------ | -------------------------------- |
| Static Dispatch   | 🚀 Fastest | ❌ No         | Structs, final classes, generics |
| V-Table (dynamic) | ⚡ Fast     | ✅ Yes        | Class inheritance                |
| Obj-C Runtime     | 🐢 Slower  | ✅ Yes        | Interoperability, selectors      |

---
