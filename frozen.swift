//
//  frozen.swift
//  
//
//  Created by Apple on 08/06/25.
//

import Foundation

`@frozen` attribute in Swift is a **compiler-level optimization hint** used primarily for **library evolution**. It's important if you're designing **public APIs** in Swift modules that other developers or apps will import.

---

## 🧊 What is `@frozen` in Swift?

The `@frozen` attribute tells the **Swift compiler**:

> "The layout of this type is **fixed** and **won’t change** in future versions of the module."

Because of this guarantee, the compiler can **optimize** how the type is used — especially when **switching over enums** or accessing structs across module boundaries.

---

## ✅ When Do You Use It?

You apply `@frozen` to:

1. **Public enums**
2. **Public structs**

> 📦 Only makes sense in **public APIs** (e.g., frameworks or libraries).

---

### 📦 Example: Frozen Enum

```swift
@frozen
public enum NetworkStatus {
    case connected
    case disconnected
}
```

### ✅ Benefit:

* The compiler can **optimize switch statements** because it knows the enum cases will **never change**.

### ❌ Risk:

* You **can't add new cases** in future versions without breaking source compatibility.

---

### 🧊 Without `@frozen`

If you **don’t** mark an enum as `@frozen`, the compiler:

* Requires clients to include a `default` case when switching.
* Prevents some optimizations to allow for future changes.

```swift
public enum ResponseCode {
    case success
    case failure
}

// In another module:
func handle(code: ResponseCode) {
    switch code {
    case .success:
        print("OK")
    case .failure:
        print("Failed")
    // No error here, because the enum is *not* frozen
    }
}
```

---

## 💡 When to Use or Avoid `@frozen`

| Use Case                             | Should You Use `@frozen`? |
| ------------------------------------ | ------------------------- |
| Public API you **control long-term** | ✅ Yes                     |
| You **may need to add cases later**  | ❌ No                      |
| Internal-only code                   | ❌ Unnecessary             |
| Performance-critical enums           | ✅ Helpful                 |

---

## 🧠 Summary

| Feature                      | `@frozen`                       |
| ---------------------------- | ------------------------------- |
| Meaning                      | Enum or struct layout is fixed  |
| Scope                        | Public enums/structs            |
| Allows future changes?       | ❌ No (locked layout)            |
| Optimizes switch statements? | ✅ Yes                           |
| Used for                     | Library evolution + performance |

---

