//
//  AsyncStream for NotificationCenter.swift
//  
//
//  Created by Apple on 17/03/25.
//

import Foundation

/ Create an AsyncStream to listen for notifications
func createNotificationStream(name: Notification.Name) -> AsyncStream<Notification> {
    return AsyncStream { continuation in
        // Create an observer for the given notification name
        let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { notification in
            // Yield the notification to the AsyncStream
            continuation.yield(notification)
        }

        // When the stream is canceled or finished, remove the observer
        continuation.onTermination = { _ in
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

### Explanation:
AsyncStream<Notification>`**: The stream emits `Notification` objects as values. Each time a new notification matching the specified `Notification.Name` is posted, the stream will yield that notification.
addObserver(forName:object:queue:)`**: This is a `NotificationCenter` API that listens for notifications with the given name. It triggers a closure when the notification is posted.
continuation.yield(notification)`**: Each time the notification is received, it’s yielded to the `AsyncStream`, which will send it to any consumers of the stream.
continuation.onTermination`**: When the stream is terminated (either manually or by cancellation), this block ensures the observer is removed from `NotificationCenter` to avoid memory leaks or retaining unnecessary references.


                                                                                            
###Consume the Stream in SwiftUI or any Async Context
                                                                                            
import SwiftUI
struct NotificationView: View {
    @State private var notifications: [String] = []
    
    var body: some View {
        VStack {
            Text("Notifications Received:")
                .font(.title)
                .padding()
            
            List(notifications, id: \.self) { notification in
                Text(notification)
            }
            .onAppear {
                startListeningToNotifications()
            }
        }
        .padding()
    }
    
    func startListeningToNotifications() {
        Task {
            // Create an AsyncStream that listens for "MyNotification" notifications
            let notificationStream = createNotificationStream(name: .init("MyNotification"))
            
            // Asynchronously listen to the notifications
            for await notification in notificationStream {
                // Extract the name of the notification and append it to the list
                if let name = notification.name.rawValue as? String {
                    notifications.append("Received: \(name)")
                }
            }
        }
    }
}


### Post a notification
import SwiftUI
import Foundation

// AsyncStream to listen for notifications
func createNotificationStream(name: Notification.Name) -> AsyncStream<Notification> {
    return AsyncStream { continuation in
        let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { notification in
            continuation.yield(notification)
        }
        
        continuation.onTermination = { _ in
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

struct NotificationView: View {
    @State private var notifications: [String] = []

    var body: some View {
        VStack {
            Text("Notifications Received:")
                .font(.title)
                .padding()

            List(notifications, id: \.self) { notification in
                Text(notification)
            }
            .onAppear {
                startListeningToNotifications()
            }

            Button(action: {
                // Post a test notification
                NotificationCenter.default.post(name: .init("MyNotification"), object: nil)
            }) {
                Text("Post Notification")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }

    func startListeningToNotifications() {
        Task {
            let notificationStream = createNotificationStream(name: .init("MyNotification"))

            for await notification in notificationStream {
                // Extract the name of the notification and append it to the list
                notifications.append("Received: \(notification.name.rawValue)")
            }
        }
    }
}

@main
struct NotificationCenterApp: App {
    var body: some Scene {
        WindowGroup {
            NotificationView()
        }
    }
}
