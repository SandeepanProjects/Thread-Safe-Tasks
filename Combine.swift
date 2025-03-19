//
//  Combine.swift
//  
//
//  Created by Apple on 19/03/25.
//

import Foundation

// CurrentValueSubject

// Create a CurrentValueSubject
let currentValueSubject = CurrentValueSubject<Int, Never>(0)

// Subscribe to it
let subscription = currentValueSubject.sink { value in
    print("Received value: \(value)")
}

// Send new values through the subject
currentValueSubject.send(1)  // Output: Received value: 1
currentValueSubject.send(2)  // Output: Received value: 2

// Current value can be accessed directly
print("Current value: \(currentValueSubject.value)")  // Output: Current value: 2
//


//Key Characteristics:
//
//Holds a current value: It always has a value, and it stores the most recent value that has been sent through it.
//Initial value: You provide an initial value when you create a CurrentValueSubject.
//Publishes updates: When you send a new value through the subject (using the send method), subscribers receive the updated value.
//Behaves like a state holder: It’s ideal for representing things like settings or a shared piece of state that multiple parts of your app need to react to.
                                                
                                                
//zip

// Create two publishers
let publisher1 = PassthroughSubject<Int, Never>()
let publisher2 = PassthroughSubject<String, Never>()

// Use zip to combine them
let subscription = Publishers.Zip(publisher1, publisher2)
    .sink { value1, value2 in
        print("Received values: \(value1), \(value2)")
    }

// Send values through the publishers
publisher1.send(1)
publisher2.send("A")  // Output: Received values: 1, A

publisher1.send(2)
publisher2.send("B")  // Output: Received values: 2, B

The zip operator emits values as tuples. For example, if you have two publishers, you get a tuple of their values ((value1, value2)).
Emits only when all publishers emit: zip will wait until each of the combined publishers has emitted a value before emitting a combined value.
It works only with publishers that emit the same number of values.

                                                            
//combineLatest

// Create two publishers
let publisher1 = PassthroughSubject<Int, Never>()
let publisher2 = PassthroughSubject<String, Never>()

// Use combineLatest to combine the latest values from both publishers
let subscription = Publishers.CombineLatest(publisher1, publisher2)
    .sink { value1, value2 in
    print("Combined values: \(value1), \(value2)")
}

// Send values through the publishers
publisher1.send(1)    // No output yet
publisher2.send("A")  // Output: Combined values: 1, A
publisher1.send(2)    // Output: Combined values: 2, A
publisher2.send("B")  // Output: Combined values: 2, B

//Emission Triggered by Any Publisher: combineLatest emits a new value every time any of the publishers emit a new value. It doesn't wait for all publishers to emit.
//Always Has Latest Values: After an initial emission, combineLatest always uses the most recent values from all the publishers.


//PassthroughSubject

// Create a PassthroughSubject
let passthroughSubject = PassthroughSubject<String, Never>()

// Subscribe to the subject
let subscription = passthroughSubject.sink { value in
    print("Received value: \(value)")
}

// Send values to the subject
passthroughSubject.send("Hello, Combine!")  // Output: Received value: Hello, Combine!
passthroughSubject.send("PassthroughSubject") // Output: Received value: PassthroughSubject

//Does not hold any value and does not replay values to new subscribers.
//It only sends values after a subscription is made.
