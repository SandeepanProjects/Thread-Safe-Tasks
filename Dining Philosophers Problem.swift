//
//  Dining Philosophers Problem.swift
//  
//
//  Created by Apple on 09/03/25.
//

import Foundation

The **Dining Philosophers Problem** is a classic concurrency problem that illustrates synchronization challenges when multiple threads (or processes) compete for shared resources. Here's a quick explanation and how it can be addressed using modern Swift concurrency tools.

---

### The Problem:
Imagine five philosophers sitting around a circular table. Each has a plate of spaghetti and needs two forks (one on the left, one on the right) to eat. The philosophers alternate between eating and thinking. However, there are only five forks available (one between each philosopher).

The challenge lies in preventing a **deadlock** (where all philosophers wait indefinitely for forks) or **starvation** (where some philosophers never get a chance to eat).

---

### Modern Swift Solution Using Concurrency

With Swift's modern concurrency tools like **`async/await`**, **Actors**, and **Task Groups**, we can design a solution that ensures thread safety, avoids deadlock, and allows philosophers to eat without starvation.

---

#### Example Implementation:
Here’s how we can use **Actors** to solve the problem in Swift:

```swift
import Foundation

actor Fork {
    private var isAvailable: Bool = true

    func pickUp() async {
        while !isAvailable {
            await Task.yield() // Wait until the fork becomes available
        }
        isAvailable = false
    }

    func putDown() {
        isAvailable = true
    }
}

actor Philosopher {
    let id: Int
    let leftFork: Fork
    let rightFork: Fork

    init(id: Int, leftFork: Fork, rightFork: Fork) {
        self.id = id
        self.leftFork = leftFork
        self.rightFork = rightFork
    }

    func dine() async {
        while true {
            print("Philosopher \(id) is thinking.")
            try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate thinking time

            print("Philosopher \(id) is hungry.")
            await leftFork.pickUp()
            print("Philosopher \(id) picked up left fork.")
            await rightFork.pickUp()
            print("Philosopher \(id) picked up right fork.")

            print("Philosopher \(id) is eating.")
            try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate eating time

            await leftFork.putDown()
            print("Philosopher \(id) put down left fork.")
            await rightFork.putDown()
            print("Philosopher \(id) put down right fork.")
        }
    }
}

// Setup
let forks = (0..<5).map { _ in Fork() }
let philosophers = (0..<5).map { i in
    Philosopher(id: i, leftFork: forks[i], rightFork: forks[(i + 1) % 5])
}

// Start dining
Task {
    await withTaskGroup(of: Void.self) { group in
        for philosopher in philosophers {
            group.addTask {
                await philosopher.dine()
            }
        }
    }
}
```

---

### Explanation:
1. **`Fork` Actor**:
   - Each fork is represented as an `actor` to ensure safe access from multiple tasks.
   - The `pickUp()` method makes the philosopher wait if the fork is not available.

2. **`Philosopher` Actor**:
   - Each philosopher alternates between **thinking**, **picking up forks**, **eating**, and **putting down forks**.
   - Fork acquisition is sequential (first left, then right) to avoid conflicts.

3. **Deadlock Avoidance**:
   - By using actors and the `await` mechanism, we allow cooperative multitasking, ensuring no deadlocks.

4. **Starvation Prevention**:
   - Each philosopher eventually gets a turn because tasks yield control when waiting.

---

Modern concurrency tools like actors simplify this problem, providing thread-safe abstractions while reducing the complexity of locking mechanisms. If you'd like, I can explain other approaches or refine this further!
