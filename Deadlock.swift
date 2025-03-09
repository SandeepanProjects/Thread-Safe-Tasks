//
//  Deadlock.swift
//  
//
//  Created by Apple on 09/03/25.
//

import Foundation

### What is a Deadlock?

A **deadlock** is a situation in concurrent programming where two or more threads (or processes) are blocked forever because they are each waiting for the other to release resources. In other words, each thread is holding a resource that the other thread is waiting for, and neither can proceed. This causes the program to freeze or stall.

A classic example of a deadlock situation:

1. Thread A locks **Resource 1** and waits for **Resource 2** to be released by Thread B.
2. Thread B locks **Resource 2** and waits for **Resource 1** to be released by Thread A.
3. Both threads are waiting for each other indefinitely.

### How to Avoid Deadlocks Using Modern Concurrency in Swift

Swift's modern concurrency framework (introduced with Swift 5.5) includes **structured concurrency** and other features that help you avoid common pitfalls like deadlocks. Here are some ways to handle and avoid deadlocks in Swift:

#### 1. **Use `async/await` to Simplify Threading and Concurrency**

Swift's **async/await** makes it easier to manage concurrency without explicitly dealing with locks or threads, thus reducing the risk of deadlocks. With `async/await`, the system schedules tasks in a structured way that ensures there's no unnecessary waiting between threads.

**Example:**

```swift
func fetchData() async throws -> Data {
    // Asynchronous operation that fetches data without blocking the main thread
    let data = try await someNetworkRequest()
    return data
}
```

By using `async/await`, the system ensures that the tasks are executed asynchronously without causing a deadlock since the thread is not locked while waiting for the result.

#### 2. **Use `Task` and `TaskGroup` for Structured Concurrency**

A `Task` is a unit of asynchronous work in Swift, and a `TaskGroup` allows you to create multiple concurrent tasks and wait for their results. These abstractions help in avoiding the misuse of threads and potential deadlock situations.

**Example:**

```swift
async {
    let task1 = Task { return await fetchData() }
    let task2 = Task { return await fetchOtherData() }
    
    let data1 = await task1.value
    let data2 = await task2.value
}
```

Here, the tasks will run concurrently, and Swift manages the synchronization internally, so you don't have to worry about deadlocks when waiting for results.

#### 3. **Locking Mechanisms in Swift: Use `NSLock`, `DispatchQueue`, or `actor`**

While Swift offers synchronization primitives like `NSLock` and `DispatchQueue`, modern Swift encourages using `actor` for protecting mutable state in a concurrent environment, which helps avoid deadlocks by ensuring that only one task can access an actor's mutable state at a time.

- **Avoid Nested Locks:** A common cause of deadlocks occurs when one lock is held while waiting for another. To avoid this, always try to acquire locks in a consistent order.
  
**Example using `actor` to avoid deadlock:**

```swift
actor DataManager {
    private var data = [String: String]()

    func updateData(key: String, value: String) {
        data[key] = value
    }

    func fetchData(for key: String) -> String? {
        return data[key]
    }
}
```

Here, the `actor` ensures that only one thread can access the mutable state at a time, automatically preventing race conditions and deadlocks.

#### 4. **Use `DispatchQueue` and Prioritize Task Execution**

When using `DispatchQueue`, try to avoid locking the same queue from multiple places. For example, if you're using a serial queue to manage critical sections, don't try to lock the same queue recursively, as this will cause a deadlock.

**Example of safe use of `DispatchQueue`:**

```swift
let serialQueue = DispatchQueue(label: "com.example.serialQueue")

func performTask() {
    serialQueue.async {
        // Perform some task that doesn't block the queue
        print("Task is running...")
    }
}
```

With this setup, the tasks are performed serially, ensuring no race conditions or deadlocks.

#### 5. **Use `try?` and `try await` for Safe Error Handling**

When dealing with concurrency, it's important to handle errors gracefully to avoid situations where the system locks and waits for an error state to resolve. Using `try?` or `try await` with proper error handling can help prevent these deadlock situations.

**Example:**

```swift
func fetchDataFromAPI() async {
    do {
        let data = try await getAPIResponse()
        // Process data
    } catch {
        // Handle error without causing a deadlock
        print("Error fetching data: \(error)")
    }
}
```

#### 6. **Use Timeout Mechanisms**

If you're dealing with locks or waiting for resources to become available, consider implementing a timeout mechanism to avoid indefinite blocking. If a task can't acquire a lock or resource within a given time frame, it should handle the timeout gracefully instead of waiting forever.

**Example using a timeout with `DispatchQueue`:**

```swift
let timeout = DispatchTime.now() + .seconds(5)
let result = DispatchQueue.global().sync(timeout: timeout) {
    // Simulate some blocking task
    return "Success"
}
```

In this example, if the task doesn't complete in the specified time frame, it won't block forever, helping you avoid a deadlock scenario.

### Key Takeaways

- **Use `async/await`**: Simplifies asynchronous programming and prevents common concurrency pitfalls.
- **Actors**: Use actors to protect mutable state in a way that avoids race conditions and deadlocks.
- **Structured Concurrency**: Swift's structured concurrency model helps avoid common deadlock-prone patterns.
- **Careful with Locks**: Use locks (e.g., `NSLock`, `DispatchQueue`) cautiously and avoid nested or recursive locks.
- **Error Handling**: Always handle errors gracefully to avoid indefinite blocking.

By utilizing these modern concurrency mechanisms, you can design more efficient and deadlock-free Swift applications.
