//
//  Priority inversion GCD.swift
//  
//
//  Created by Apple on 10/03/25.
//

import Foundation

Priority inversion occurs when a higher-priority task is waiting for a lower-priority task to release a resource, but the lower-priority task cannot proceed because it’s blocked by another even lower-priority task. This can lead to performance issues or deadlocks in real-time systems, as the higher-priority task is unable to execute despite its urgency.
                                                                        
let queueHigh = DispatchQueue(label: "com.example.high", qos: .userInteractive)
let queueLow = DispatchQueue(label: "com.example.low", qos: .background)

var sharedResource = 0

// High priority task
queueHigh.async {
    print("High priority task: waiting for resource")
    while sharedResource == 0 {
        // Simulate waiting for resource (can cause priority inversion)
        usleep(100)
    }
    print("High priority task: got resource")
}

// Low priority task
queueLow.async {
    print("Low priority task: holding resource")
    sharedResource = 1
    usleep(1000) // Hold the resource for a while
    print("Low priority task: releasing resource")
    sharedResource = 0
}

// Medium priority task
let queueMedium = DispatchQueue(label: "com.example.medium", qos: .userInitiated)
queueMedium.async {
    print("Medium priority task: running")
    usleep(500) // Simulate some work
}


// Prevent Priority Inversion

let semaphore = DispatchSemaphore(value: 1)
let queueHigh = DispatchQueue(label: "com.example.high", qos: .userInteractive)
let queueLow = DispatchQueue(label: "com.example.low", qos: .background)

var sharedResource = 0

// High priority task
queueHigh.async {
    print("High priority task: waiting for resource")
    semaphore.wait()  // Wait to acquire the semaphore
    print("High priority task: got resource")
    // Perform the task
    semaphore.signal()  // Release the semaphore
}

// Low priority task
queueLow.async {
    print("Low priority task: holding resource")
    semaphore.wait()  // Acquire the semaphore
    sharedResource = 1
    usleep(1000) // Hold the resource for a while
    print("Low priority task: releasing resource")
    semaphore.signal()  // Release the semaphore
}
