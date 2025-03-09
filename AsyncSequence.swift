//
//  AsyncSequence.swift
//  
//
//  Created by Apple on 09/03/25.
//

import Foundation

Key Features of AsyncSequence:

Asynchronous Iteration: You iterate over its values using a for await loop.
Suspension Point: When fetching the next element, the iteration can asynchronously pause (await) until the next element is ready.
Error Handling: Similar to throws, an AsyncSequence can signal errors during iteration.
Cancellation: Iteration can be cancelled, especially when used with Task.

import Foundation
                                                                    
// A custom AsyncSequence
struct Countdown: AsyncSequence {
    typealias Element = Int
    
    let start: Int
    
    // The AsyncIterator for the sequence
    struct AsyncIterator: AsyncIteratorProtocol {
        var current: Int
        
        mutating func next() async -> Int? {
            guard current > 0 else { return nil }
            let nextValue = current
            current -= 1
            try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulate a delay
            return nextValue
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(current: start)
    }
}

// Using the AsyncSequence
Task {
    let countdown = Countdown(start: 5)
    
    for await number in countdown {
        print("Countdown: \(number)")
    }
    print("Done!")
}
