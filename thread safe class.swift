//
//  thread safe class.swift
//  
//
//  Created by Apple on 09/03/25.
//

import Foundation

class ThreadSafeCounter {
    private var counter = 0
    // Create a concurrent DispatchQueue
    private let queue = DispatchQueue(label: "com.example.counterQueue", attributes: .concurrent)

    // Method to increment the counter in a thread-safe way using Dispatch Barrier
    func increment() {
        queue.async(flags: .barrier) {
            self.counter += 1
        }
    }

    // Method to decrement the counter in a thread-safe way using Dispatch Barrier
    func decrement() {
        queue.async(flags: .barrier) {
            self.counter -= 1
        }
    }

    // Method to get the current counter value in a thread-safe way
    func getCounter() -> Int {
        var value = 0
        // Perform the read operation concurrently without blocking other tasks
        queue.sync {
            value = self.counter
        }
        return value
    }
}

// Usage Example

let counter = ThreadSafeCounter()

// Concurrently increment and read the counter
DispatchQueue.global().async {
    for _ in 0..<10 {
        counter.increment()
        print("Incremented: \(counter.getCounter())")
    }
}

DispatchQueue.global().async {
    for _ in 0..<10 {
        counter.decrement()
        print("Decremented: \(counter.getCounter())")
    }
}

// Sleep to let the asynchronous tasks complete
DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
    print("Final Counter Value: \(counter.getCounter())")
}
