//
//  Race Condition.swift
//  
//
//  Created by Apple on 09/03/25.
//

import Foundation

// Example of a Race Condition
class Counter {
    var value = 0

    func increment() {
        value += 1
    }
}

let counter = Counter()
let queue = DispatchQueue.global()

DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    queue.async {
        counter.increment()
    }
}

print("Final Counter Value: \(counter.value)") // Likely to be less than 1000

// Avoiding the Race Condition

class Counter {
    private let queue = DispatchQueue(label: "com.counter.serial.queue")
    private var internalValue = 0

    var value: Int {
        return queue.sync { internalValue }
    }

    func increment() {
        queue.sync {
            internalValue += 1
        }
    }
}

let counter = Counter()
DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    counter.increment()
}

print("Final Counter Value: \(counter.value)") // Always 1000

//NSLock

class Counter {
    private var value = 0
    private let lock = NSLock()

    func increment() {
        lock.lock()
        value += 1
        lock.unlock()
    }

    var currentValue: Int {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
}


//DispatchSemaphore

let semaphore = DispatchSemaphore(value: 1) // 1 allows single-thread access

DispatchQueue.global().async {
    semaphore.wait()
    print("Task 1 Start")
    sleep(2) // Simulate work
    print("Task 1 End")
    semaphore.signal()
}

DispatchQueue.global().async {
    semaphore.wait()
    print("Task 2 Start")
    sleep(1) // Simulate work
    print("Task 2 End")
    semaphore.signal()
}

// Dispatch Barrier

let concurrentQueue = DispatchQueue(label: "com.example.queue", attributes: .concurrent)
var sharedResource = [Int]()

// Read operation
concurrentQueue.async {
    print(sharedResource)
}

// Write operation with a barrier
concurrentQueue.async(flags: .barrier) {
    sharedResource.append(1)
    print("Resource Updated")
}
