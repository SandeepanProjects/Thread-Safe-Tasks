//
//  Tasks.swift
//  
//
//  Created by Apple on 19/03/25.
//

import Foundation

// Define an API request function that simulates fetching data.
func fetchDataFromAPI() async throws -> String {
    // Simulate a network delay
    try await Task.sleep(nanoseconds: 3 * 1_000_000_000)  // 3 seconds

    // Simulate a successful API response
    return "API response data"
}

class APIManager {
    private var currentTask: Task<String, Error>?

    func startAPICall() {
        // Create a new task to execute the API request
        currentTask = Task {
            do {
                let data = try await fetchDataFromAPI()
                print("Received data: \(data)")
            } catch {
                if Task.isCancelled {
                    print("API request was canceled.")
                } else {
                    print("API request failed with error: \(error)")
                }
            }
        }
    }

    func cancelAPICall() {
        // Cancel the ongoing task (API request)
        currentTask?.cancel()
    }
}

// Usage:
let apiManager = APIManager()

// Start the API call
apiManager.startAPICall()

// Simulate a cancellation after 1 second (e.g., user navigated away from the screen)
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    apiManager.cancelAPICall()
}



import Foundation

func fetchDataFromAPIUsingURLSession() async throws -> Data {
    let url = URL(string: "https://example.com/api/data")!
    
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}

class APIManager {
    private var currentTask: Task<Data, Error>?

    func startAPICall() {
        currentTask = Task {
            do {
                let data = try await fetchDataFromAPIUsingURLSession()
                print("Received data: \(data)")
            } catch {
                if Task.isCancelled {
                    print("API request was canceled.")
                } else {
                    print("API request failed with error: \(error)")
                }
            }
        }
    }

    func cancelAPICall() {
        currentTask?.cancel()
    }
}

// Usage:
let apiManager = APIManager()

// Start the API call
apiManager.startAPICall()

// Simulate a cancellation after 1 second
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    apiManager.cancelAPICall()
}

