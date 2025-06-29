//
//  Closures.swift
//  
//
//  Created by Apple on 08/06/25.
//

import Foundation

## 🔐 **What is a Closure (Quick Recap)?**

A **closure** is a block of code that:

* Can be passed around like a variable.
* Can capture and store references to variables from its surrounding context (lexical scope).

---

## 🧩 **Types of Closures in Swift (and Conceptually in Other Languages)**

### 1. **Global Closures**

* Defined at the global scope (outside of any function).
* **Cannot capture values** from surrounding context.
* Useful when no external state is needed.

```swift
let sayHello = {
    print("Hello!")
}
```

---

### 2. **Nested Functions (Local Functions)**

* Named functions **defined inside another function**.
* **Can capture values** from the enclosing function.

```swift
func outerFunction() {
    var counter = 0
    func innerFunction() {
        counter += 1
        print("Counter: \(counter)")
    }
    innerFunction()
}
```

---

### 3. **Closure Expressions (Anonymous Closures)**

* **Unnamed**, inline closures, often used with functions like `map`, `filter`, `reduce`, etc.
* These closures **can capture variables** from their surrounding context.

```swift
let numbers = [1, 2, 3]
let doubled = numbers.map { $0 * 2 }  // [2, 4, 6]
```

---

### 4. **Escaping Closures**

* Closures that **outlive** the function they are passed to.
* Common in asynchronous operations (like network calls).
* You must mark them with `@escaping`.

```swift
func fetchData(completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        completion()
    }
}
```

---

### 5. **Non-Escaping Closures**

* Default in Swift.
* The closure is **used (executed) inside the function**, and does **not** outlive it.

```swift
func doSomething(task: () -> Void) {
    task()
}
```

---

### 6. **Auto Closures**

* Automatically wraps an expression in a closure.
* Used to **defer execution** without writing `{}` manually.
* Often used for **lazy evaluation** or **assertions**.

```swift
func logIfTrue(_ predicate: @autoclosure () -> Bool) {
    if predicate() {
        print("Condition was true")
    }
}

logIfTrue(2 > 1)  // `2 > 1` is automatically turned into a closure
```

---

## 🔁 Summary Table

| Type                 | Named? | Captures Context? | Escapes Function? | Common Use Case                       |
| -------------------- | ------ | ----------------- | ----------------- | ------------------------------------- |
| Global Closure       | ❌      | ❌                 | ❌                 | Standalone logic                      |
| Nested Function      | ✅      | ✅                 | ❌                 | Utility within another function       |
| Closure Expression   | ❌      | ✅                 | Optional          | `map`, `filter`, completion handlers  |
| Escaping Closure     | ❌      | ✅                 | ✅                 | Async operations, completion handlers |
| Non-Escaping Closure | ❌      | ✅                 | ❌                 | Immediate logic execution             |
| Auto Closure         | ❌      | ✅ (deferred)      | Optional          | Lazy evaluation, custom assertions    |

---

If you want, I can also show how closures differ across languages like **JavaScript**, **Python**, or **Kotlin**. Just say the word!

Sure! Here's a clear breakdown of the **difference between escaping and non-escaping closures**, especially in **Swift**, where this distinction is explicit and important.

---

## 🔁 **Escaping vs Non-Escaping Closures in Swift**

### 🟢 **Non-Escaping Closures** (Default)

**Definition:**
A closure is **non-escaping** if it's **called within the function** it's passed to.
It does **not "escape"** the function body.

#### ✅ Characteristics:

* Default behavior (no annotation needed).
* The closure is executed **synchronously** within the function.
* Cannot be stored for later use.

#### 📦 Example:

```swift
func performNow(task: () -> Void) {
    task()  // Called immediately
}
```

#### ✅ Usage:

```swift
performNow {
    print("This runs immediately.")
}
```

---

### 🔴 **Escaping Closures**

**Definition:**
A closure is **escaping** if it's **called after the function returns**, such as in asynchronous code or if stored for later use.

#### ✅ Characteristics:

* Must be marked with `@escaping`.
* Closure might be stored or executed **asynchronously**.
* Useful in **completion handlers**, network requests, etc.

#### 📦 Example:

```swift
func performLater(task: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        task()  // Called later, after function has returned
    }
}
```

#### ✅ Usage:

```swift
performLater {
    print("This runs after a delay.")
}
```

---

## 🧠 Why Does Swift Care?

Because **Swift uses value types (like structs)** and cares about **memory safety**, it needs to track when a closure **escapes** so it can manage captured variables properly. Marking closures as `@escaping` tells the compiler to retain any captured values for later execution.

---

## 🔑 Summary Table

| Feature                | Non-Escaping Closure | Escaping Closure                     |
| ---------------------- | -------------------- | ------------------------------------ |
| Default in Swift       | ✅ Yes                | ❌ No (requires `@escaping`)          |
| Called within function | ✅ Yes                | ❌ No (called after function returns) |
| Used for async logic   | ❌ No                 | ✅ Yes (e.g., network requests)       |
| Can be stored          | ❌ No                 | ✅ Yes                                |
| Needs `@escaping`      | ❌ No                 | ✅ Yes                                |

---

### 🧪 Quick Visual:

```swift
func example(@escapingClosure: @escaping () -> Void, nonEscapingClosure: () -> Void) {
    DispatchQueue.main.async {
        escapingClosure()   // Valid
    }
    nonEscapingClosure()    // Must be called immediately
}
```

---

Let me know if you'd like to see this explained in terms of memory management or with other language comparisons (e.g., JavaScript callbacks).

Certainly! Let's clearly explain the **difference between escaping and non-escaping closures in Swift**, focusing on usage, behavior, and memory management.
                
                ---
                
## 🔁 Difference Between **Escaping** and **Non-Escaping Closures** in Swift
                
                ---
                
### 🟢 **Non-Escaping Closures** (Default)
                
#### 📌 What is it?
                
A **non-escaping closure** is a closure that is **guaranteed to be executed before the function it is passed to returns**.
                
#### ✅ Key Characteristics:
                    
* It is the **default** behavior.
* You **don't** need to mark it explicitly.
* You can use `self` directly without worrying about retain cycles.
* Common in standard library methods like `map`, `filter`, etc.
                
#### 📦 Example:
                    
```swift
func performNow(task: () -> Void) {
    print("Start task")
    task()  // Executed immediately
    print("End task")
}

performNow {
    print("Running non-escaping closure")
}
```

> ✅ The closure runs immediately and doesn’t outlive the `performNow` function.

---

### 🔴 **Escaping Closures**

#### 📌 What is it?

An **escaping closure** is a closure that **might be called after the function it was passed to has returned**.

#### ✅ Key Characteristics:

* Must be marked with `@escaping`.
* Typically used in asynchronous tasks (e.g., network requests).
* Captures variables strongly by default, so you often need `[weak self]` to avoid memory leaks.

#### 📦 Example:

```swift
func performLater(task: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        task()  // Executed later
    }
}

performLater {
    print("Running escaping closure")
}
```

> ❗The closure “escapes” the scope of `performLater` and runs later, so Swift needs to manage memory accordingly.

---

## 🧠 Memory Consideration

* **Escaping closures** can **outlive the function's scope**, so captured references (like `self`) **must be weak or unowned** to avoid retain cycles.

```swift
class MyClass {
    var value = 10
    
    func call() {
        performLater { [weak self] in
            print(self?.value ?? 0)
        }
    }
}
```

* **Non-escaping closures** are **safe to use `self` directly** because they don't get stored or executed later.

---

## 🔑 Summary Table

| Feature                         | Non-Escaping Closure             | Escaping Closure                              |
| ------------------------------- | -------------------------------- | --------------------------------------------- |
| Default in Swift                | ✅ Yes                            | ❌ No (`@escaping` required)                   |
| Executed after function returns | ❌ No                             | ✅ Yes                                         |
| Needs `@escaping`               | ❌ No                             | ✅ Yes                                         |
| Can be stored/cached            | ❌ No                             | ✅ Yes                                         |
| Retain cycle risk               | ❌ Low                            | ✅ High (use `[weak self]`)                    |
| Common use case                 | `map`, `filter`, immediate tasks | Network calls, async tasks, completion blocks |

---

Great! Let’s dive into **retain cycles in closures** — a crucial concept in **Swift** memory management, especially when working with **classes** and **escaping closures**.

---

## ♻️ What is a **Retain Cycle**?

A **retain cycle** occurs when two (or more) objects **strongly reference each other**, preventing ARC (Automatic Reference Counting) from deallocating them — causing a **memory leak**.

### 🔗 Common Retain Cycle Scenario:

* Object **A** strongly holds object **B**
* Object **B** also strongly holds object **A**

Neither can be released, even if nothing else is using them.

---

## 🧠 Retain Cycles in **Closures**

In Swift, **closures capture variables** from their surrounding context by **default using strong references**.

So if a **class instance** captures `self` inside a closure, and that closure is also **stored by the class**, this creates a retain cycle:

### 🔥 Problematic Example:

```swift
class MyClass {
    var name = "Swift"
    
    // Escaping closure
    var completion: (() -> Void)?

    func setup() {
        completion = {
            print(self.name)  // Captures self strongly
        }
    }
}
```

### 🧨 What’s happening:

1. `MyClass` owns the closure via the `completion` property.
2. The closure captures `self` strongly.
3. So:

   * `MyClass ➜ closure`
   * `closure ➜ self (MyClass)`
4. ❌ **Retain cycle**: neither `MyClass` nor the closure can be deallocated.

---

## ✅ Solution: Use **Capture Lists** (`[weak self]` or `[unowned self]`)

You can **break the retain cycle** by capturing `self` **weakly** or **unowned** inside the closure.

### ✅ Safe Version:

```swift
class MyClass {
    var name = "Swift"
    var completion: (() -> Void)?

    func setup() {
        completion = { [weak self] in
            print(self?.name ?? "nil")
        }
    }
}
```

* `[weak self]` makes the closure hold a **weak reference** to the object.
* It **does not increase** the reference count, so ARC can deallocate `self` if needed.
* Use `self?` because `self` might be `nil`.

---

### 🆚 `weak` vs `unowned`

| Modifier  | Optional? | Safe if object deallocated? | Use When…                              |
| --------- | --------- | --------------------------- | -------------------------------------- |
| `weak`    | ✅ Yes     | ✅ Safe (becomes `nil`)      | When `self` can be deallocated         |
| `unowned` | ❌ No      | ❌ Crashes if `self` is nil  | When `self` **must** exist when called |

#### Example with `unowned`:

```swift
completion = { [unowned self] in
    print(self.name)
}
```

> ⚠️ Use only if you’re **certain** `self` will still exist when the closure runs.

---

## 🔁 Summary

| Topic               | Description                                                               |
| ------------------- | ------------------------------------------------------------------------- |
| Retain Cycle        | Two objects strongly reference each other, preventing deallocation        |
| In Closures         | Happens when `self` is captured strongly in an escaping closure           |
| Fix with            | `[weak self]` or `[unowned self]` in the closure’s capture list           |
| `weak` vs `unowned` | `weak` is optional and safe; `unowned` is non-optional but riskier        |
| Applies To          | Escaping closures, especially stored in properties or used asynchronously |

---

Escaping - When a **function in Swift takes an optional closure as a parameter**, the **type of the closure** is simply an **optional closure type**.

---

## 📌 Syntax

If a closure is optional, its type is written like this:

```swift
(() -> Void)?
```

This means:

* The function accepts either:

  * a closure of type `() -> Void`, or
  * `nil`.

---

## ✅ Example: Optional Closure Parameter

```swift
func doSomething(completion: (() -> Void)?) {
    print("Doing work...")
    completion?()  // Use optional chaining to call it safely
}
```

### 🧠 Explanation:

* `completion` is an optional closure.
* So you **must use `?`** to call it safely: `completion?()`.
* If `completion` is `nil`, nothing happens.

---

## ✅ Usage Examples:

```swift
// With a closure
doSomething {
    print("Task completed")
}

// With nil
doSomething(completion: nil)
```

---

## 🔍 Closure Type Breakdown

| Closure Declaration  | Meaning                                   |
| -------------------- | ----------------------------------------- |
| `() -> Void`         | A non-optional closure that takes no args |
| `(() -> Void)?`      | An **optional** closure that may be `nil` |
| `(Int) -> String`    | Takes an `Int`, returns a `String`        |
| `((Int) -> String)?` | Optional closure with same signature      |

---

### ⚠️ What If You Don’t Use Optional?

If you declare the closure like this:

```swift
func doSomethingNonOptional(completion: () -> Void) {
    completion()  // Must call it — can't be nil
}
```

Then you are **required to pass a closure**, and it **can’t be nil**.

---

## ✅ Summary

| Concept               | Example                                     |
| --------------------- | ------------------------------------------- |
| Optional closure type | `(() -> Void)?`                             |
| Non-optional closure  | `() -> Void`                                |
| Safe call             | `completion?()`                             |
| Use case              | When the closure is optional or defaultable |

---


