//
//  AsyncStream.swift
//  
//
//  Created by Apple on 09/03/25.
//

import Foundation

// Create an AsyncStream that simulates a stream of integers
let stream = AsyncStream<Int> { continuation in
    Task {
        for i in 0..<5 {
            await Task.sleep(1 * 1_000_000_000) // Simulate delay (1 second)
            continuation.yield(i) // Send value to the stream
        }
        continuation.finish() // Finish the stream after sending all values
    }
}

// Iterate over the AsyncStream asynchronously
Task {
    for await value in stream {
        print("Received value: \(value)")
    }
}


//Real-World Scenarios:

//Example: GPS Location Updates


// Simulating a stream of GPS location updates
class GPSStream {
    let stream: AsyncStream<String>
    
    init() {
        self.stream = AsyncStream { continuation in
            Task {
                // Simulate continuous GPS location updates
                let locations = ["Location 1", "Location 2", "Location 3", "Location 4"]
                for location in locations {
                    await Task.sleep(2 * 1_000_000_000) // Simulate 2 seconds delay between updates
                    continuation.yield(location)
                }
                continuation.finish()
            }
        }
    }
}

// Usage example

Task {
    let gpsStream = GPSStream()

    for await location in gpsStream.stream {
        print("Received location: \(location)")
    }
}


// Network Responses with Streaming APIs
// Simulating Download of Large File Chunks


class FileDownloader {
    let stream: AsyncStream<Data>
    
    init() {
        self.stream = AsyncStream { continuation in
            Task {
                // Simulating downloading file in chunks (e.g., 1 MB per chunk)
                for i in 0..<5 {
                    await Task.sleep(2 * 1_000_000_000) // Simulate delay between chunks
                    let chunk = Data(repeating: UInt8(i), count: 1_000_000) // 1 MB chunk
                    continuation.yield(chunk)
                }
                continuation.finish()
            }
        }
    }
}

// Usage example

Task {
    let downloader = FileDownloader()
    
    for await chunk in downloader.stream {
        print("Received file chunk: \(chunk.count) bytes")
    }
}


// User Input or Events in Real-Time

class ButtonPressStream {
    let stream: AsyncStream<String>
    
    init() {
        self.stream = AsyncStream { continuation in
            Task {
                let buttonPresses = ["Button Press 1", "Button Press 2", "Button Press 3"]
                for press in buttonPresses {
                    await Task.sleep(1 * 1_000_000_000) // Simulate delay between button presses
                    continuation.yield(press)
                }
                continuation.finish()
            }
        }
    }
}

// Usage example

Task {
    let buttonStream = ButtonPressStream()
    
    for await press in buttonStream.stream {
        print("Received: \(press)")
    }
}


// WebSocket or Real-Time Messaging (e.g., Chat)
// Receiving and processing real-time messages in a chat application or similar use cases.
class ChatStream {
    let stream: AsyncStream<String>
    
    init() {
        self.stream = AsyncStream { continuation in
            Task {
                let messages = ["Hello!", "How are you?", "Goodbye!"]
                for message in messages {
                    await Task.sleep(1 * 1_000_000_000) // Simulate delay between messages
                    continuation.yield(message)
                }
                continuation.finish()
            }
        }
    }
}

// Usage example

Task {
    let chatStream = ChatStream()
    
    for await message in chatStream.stream {
        print("Received message: \(message)")
    }
}
