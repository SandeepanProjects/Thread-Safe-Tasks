//
//  Notification Service Extension.swift
//  
//
//  Created by Apple on 06/04/25.
//

Notification Service Extension has a time limit (about 30 seconds) to finish processing the notification. If this time is exceeded, the notification is delivered without modifications. Make sure your logic within the extension runs efficiently.


Notification Service Extension Code

import UserNotifications
import Foundation

class NotificationService: UNNotificationServiceExtension {

    override func didReceive(_ request: UNNotificationRequest,
                              withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        // Get the notification content
        let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        // Modify the notification's content (e.g., add an image, change the title)
        if let bestAttemptContent = bestAttemptContent {
            // Example: Add a custom attachment (e.g., image or video from the URL)
            if let imageURLString = bestAttemptContent.userInfo["image_url"] as? String,
               let imageURL = URL(string: imageURLString) {
                downloadImage(from: imageURL) { (imageData) in
                    if let imageData = imageData, let attachment = createAttachment(from: imageData) {
                        bestAttemptContent.attachments = [attachment]
                    }
                    
                    // Continue with the notification delivery
                    contentHandler(bestAttemptContent)
                }
            } else {
                // If no image, just continue with the notification delivery
                contentHandler(bestAttemptContent)
            }
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called when the extension is about to be terminated due to time limits.
        // Deliver the notification content before the extension is terminated.
        let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        contentHandler(bestAttemptContent ?? request.content)
    }

    // Helper function to download the image data
    private func downloadImage(from url: URL, completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                completion(data)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }

    // Helper function to create an attachment from image data
    private func createAttachment(from data: Data) -> UNNotificationAttachment? {
        do {
            let tempDirectory = FileManager.default.temporaryDirectory
            let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
            try data.write(to: tempURL)
            return try UNNotificationAttachment(identifier: "image", url: tempURL, options: nil)
        } catch {
            print("Error creating attachment: \(error)")
            return nil
        }
    }
}

didReceive(_:withContentHandler:): This method is called when a push notification is received. You can modify the notification's content, download additional data, or add attachments (like images) here.
serviceExtensionTimeWillExpire(): This method is called if the extension runs out of time before delivering the notification. You should ensure to call the contentHandler in this method to deliver the notification, even if you have to abandon any modifications.



{
    "aps": {
        "alert": {
            "title": "New message",
            "body": "You've got a new message!"
        },
        "sound": "default"
    },
    "image_url": "https://example.com/path/to/image.jpg"
}


Handle App Permissions

import UserNotifications

UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
    if granted {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}

