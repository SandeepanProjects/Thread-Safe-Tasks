//
//  Thread Safety.swift
//  
//
//  Created by Apple on 08/06/25.
//

import Foundation

To make a **variable thread-safe** in Swift, you need to ensure that **concurrent access** to the variable doesn't lead to **data races** or **inconsistent state**. There are several ways to achieve this depending on the use case.

---

## 🧠 Why Is Thread Safety Important?

If multiple threads **read and write** a shared variable simultaneously **without synchronization**, it can cause:

* Crashes
* Corrupted data
* Unexpected behavior

---

## ✅ Common Ways to Make a Variable Thread-Safe in Swift

---

### 1. 🔒 **Serial Dispatch Queue**

Use a private **serial `DispatchQueue`** to synchronize access.

```swift
class ThreadSafeCounter {
    private var value = 0
    private let queue = DispatchQueue(label: "com.example.counter")

    func increment() {
        queue.sync {
            value += 1
        }
    }

    func get() -> Int {
        return queue.sync { value }
    }
}
```

✅ **Safe:** Only one thread can access `value` at a time.

---

### 2. 🧵 **Dispatch Barrier (for concurrent queues)**

Use a **concurrent queue** with a **barrier** to allow simultaneous reads but exclusive writes.

```swift
class ThreadSafeData<T> {
    private var _value: T
    private let queue = DispatchQueue(label: "com.example.data", attributes: .concurrent)

    init(_ value: T) {
        _value = value
    }

    var value: T {
        get {
            queue.sync {
                return _value
            }
        }
        set {
            queue.async(flags: .barrier) {
                self._value = newValue
            }
        }
    }
}
```

✅ **Safe and performant**: Allows concurrent reads, serializes writes.

---

### 3. 🧱 **NSLock**

Use `NSLock` to manually lock and unlock around critical sections.

```swift
class LockedCounter {
    private var value = 0
    private let lock = NSLock()

    func increment() {
        lock.lock()
        value += 1
        lock.unlock()
    }

    func get() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
}
```

✅ Flexible, but you **must remember to unlock**, or you risk deadlock.

---

### 4. 🔁 **Atomic Property Wrapper (Custom)**

You can wrap atomic behavior in a reusable Swift property wrapper:

```swift
@propertyWrapper
class Atomic<Value> {
    private var value: Value
    private let lock = NSLock()

    var wrappedValue: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return value
        }
        set {
            lock.lock()
            value = newValue
            lock.unlock()
        }
    }

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
}

// Usage
class Example {
    @Atomic var counter = 0
}
```

---

### 5. ⚙️ **Combine with Actors (Swift Concurrency)** *(Swift 5.5+)*

In Swift’s modern concurrency model, **actors** provide built-in thread safety.

```swift
actor Counter {
    private var value = 0

    func increment() {
        value += 1
    }

    func get() -> Int {
        return value
    }
}
```

✅ Simple and thread-safe by default — perfect for new Swift codebases.

---

## ✅ Summary: Thread Safety Techniques

| Technique            | Best For                       | Notes                                        |
| -------------------- | ------------------------------ | -------------------------------------------- |
| Serial DispatchQueue | Most common/general use        | Easy and reliable                            |
| Dispatch Barrier     | High-read, low-write scenarios | Efficient but more complex                   |
| NSLock               | Fine-grained control           | Must manually lock/unlock (risk of bugs)     |
| Property Wrapper     | Reusability and clean syntax   | Great for shared value types                 |
| Actor (`Swift 5.5+`) | Modern Swift concurrency       | Safe and simple, uses structured concurrency |

---

Would you like a sample app demonstrating these techniques with thread testing (e.g., via `DispatchQueue.concurrentPerform`)?
