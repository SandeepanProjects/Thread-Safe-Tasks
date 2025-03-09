//
//  Real-World Example AsyncSequence.swift
//  
//
//  Created by Apple on 09/03/25.
//

import Foundation

//Imagine you're building a chat application where the client receives messages from a WebSocket server in real-time. Swift's AsyncSequence can help process the incoming data stream asynchronously.

// WebSocketManager for streaming messages asynchronously
class WebSocketManager {
    private var isConnected = false

    func connect(to url: URL) -> AsyncStream<String> {
        return AsyncStream { continuation in
            // Simulate connection
            isConnected = true
            print("Connected to WebSocket at \(url)")

            // Simulate receiving messages asynchronously
            DispatchQueue.global().async {
                let messages = ["Hello!", "How are you?", "Goodbye!"]
                for message in messages {
                    sleep(1) // Simulate network delay
                    continuation.yield(message)
                }
                continuation.finish() // End the stream
            }

            // Handle cancellation
            continuation.onTermination = { _ in
                self.isConnected = false
                print("Disconnected from WebSocket")
            }
        }
    }
}

// Using WebSocketManager with AsyncSequence
let webSocketManager = WebSocketManager()
let url = URL(string: "wss://example-chat-app.com")!

Task {
    let messageStream = webSocketManager.connect(to: url)

    // Process messages as they arrive
    for await message in messageStream {
        print("Received message: \(message)")
    }

    print("All messages received.")
}

//How This Works:
//
//Connect to WebSocket:
//The connect(to:) method returns an AsyncStream of messages from the WebSocket.
//Simulate Data Stream:
//Messages are yielded to the AsyncStream one at a time, simulating real-time arrival.
//Iterate with for await:
//The for await loop processes each message as it becomes available, pausing execution until the next message is ready.
//Cancellation:
//If the task running the for await loop is cancelled, the stream terminates gracefully.


//Polling Server for Updates
//Sometimes, an app needs to regularly poll a server for data, such as checking for updates, new messages, or notifications. An AsyncSequence can be used to poll the server at regular intervals without blocking the main thread.


class ServerPollingStream {
    let stream: AsyncStream<String>
    
    init() {
        self.stream = AsyncStream { continuation in
            Task {
                // Simulate polling the server every 5 seconds
                let updates = ["Update 1", "Update 2", "Update 3"]
                for update in updates {
                    await Task.sleep(5 * 1_000_000_000) // Simulate 5-second polling interval
                    continuation.yield(update) // Yield each update to the stream
                }
                continuation.finish() // End the stream
            }
        }
    }
}

// Usage example

Task {
    let pollingStream = ServerPollingStream()
    
    // Process server updates as they arrive
    for await update in pollingStream.stream {
        print("Received update: \(update)")
    }
}
