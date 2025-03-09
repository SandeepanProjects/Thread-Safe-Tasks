//
//  Priority Inversion.swift
//  
//
//  Created by Apple on 10/03/25.
//

import Foundation

//How to Avoid Priority Inversion:
//
//Priority Inheritance using Task

// Simulate a priority inversion scenario
actor Resource {
    var isAvailable = true
    
    // Simulate a long operation that holds the resource
    func holdResource() {
        print("Resource is now held.")
        Thread.sleep(forTimeInterval: 2)
        print("Resource is released.")
    }
}

func highPriorityTask(resource: Resource) async {
    print("High priority task waiting for resource...")
    await resource.holdResource()
    print("High priority task completed.")
}

func lowPriorityTask(resource: Resource) async {
    print("Low priority task using the resource.")
    await resource.holdResource()
    print("Low priority task completed.")
}

func mediumPriorityTask(resource: Resource) async {
    print("Medium priority task waiting for resource...")
    await resource.holdResource()
    print("Medium priority task completed.")
}

Task {
    // Simulate high, medium, and low-priority tasks running concurrently.
    async let low = lowPriorityTask(resource: Resource())
    async let medium = mediumPriorityTask(resource: Resource())
    async let high = highPriorityTask(resource: Resource())

    // Wait for all tasks to finish.
    await [low, medium, high]
}


// Priority Inversion and Swift's Task with Custom Priorities:

// An actor protecting the resource.
actor Resource {
    private var isAvailable = true
    
    func performAction() {
        print("Performing resource action...")
        Thread.sleep(forTimeInterval: 2) // Simulating work
        print("Action completed.")
    }
}

func highPriorityTask(resource: Resource) async {
    print("High priority task waiting for resource...")
    await resource.performAction()
    print("High priority task completed.")
}

func lowPriorityTask(resource: Resource) async {
    print("Low priority task started.")
    await resource.performAction()
    print("Low priority task completed.")
}

// Simulating the tasks running with concurrency
Task {
    async let low = lowPriorityTask(resource: Resource())
    async let high = highPriorityTask(resource: Resource())

    await [low, high]
}
