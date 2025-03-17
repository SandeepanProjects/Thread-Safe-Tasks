//
//  Asynchronous Timer With AsyncStream.swift
//  
//
//  Created by Apple on 17/03/25.
//

import Foundation

// Create an asynchronous timer with AsyncStream
func createAsyncTimer(interval: TimeInterval) -> AsyncStream<Int> {
    return AsyncStream { continuation in
        var count = 0
        Task {
            while true {
                // Wait for the specified interval
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                
                // Emit the count value
                continuation.yield(count)
                
                // Increment the count for the next value
                count += 1
            }
        }
    }
}

Explanation:

AsyncStream<Int>`**: This stream will emit `Int` values, where each value represents the number of seconds passed since the start of the timer.
continuation.yield(count)`**: This is how you emit a value in an `AsyncStream`. It pushes the current `count` value to the stream.
Task.sleep`**: This function is used to introduce a delay before emitting the next value. The timer interval is specified in seconds (`interval`), and we convert it to nanoseconds (the unit used by `Task.sleep`).

import SwiftUI

struct TimerView: View {
    @State private var elapsedTime: Int = 0
    @State private var timerRunning: Bool = false
    
    // Define a task to hold the asynchronous timer
    @State private var timerTask: Task<Void, Never>? = nil
    
    var body: some View {
        VStack {
            Text("Elapsed Time: \(elapsedTime) seconds")
                .font(.largeTitle)
                .padding()
            
            HStack {
                Button(action: {
                    if timerRunning {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                }) {
                    Text(timerRunning ? "Stop Timer" : "Start Timer")
                        .font(.title)
                        .padding()
                        .background(timerRunning ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .padding()
    }
    
    // Start the asynchronous timer
       func startTimer() {
           timerRunning = true
           timerTask = Task {
               // Create an asynchronous timer with a 1-second interval
               let timerStream = createAsyncTimer(interval: 1)

               // Iterate through the timer stream
               for await count in timerStream {
                   // Update the elapsed time every second
                   elapsedTime = count
               }
           }
       }

       // Stop the timer
       func stopTimer() {
           timerRunning = false
           timerTask?.cancel()
       }
   }

   struct TimerView_Previews: PreviewProvider {
       static var previews: some View {
           TimerView()
       }
   }
