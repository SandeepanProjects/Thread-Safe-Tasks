//
//  AnalyticsManager.swift
//  
//
//  Created by Apple on 19/03/25.
//

import Foundation
import FirebaseAnalytics  // Example with Firebase (you can replace with any other SDK)

class AnalyticsManager {

    // Shared instance (Singleton)
    static let shared = AnalyticsManager()

    private init() { }

    // Example of logging an event with parameters
    func logEvent(eventName: String, parameters: [String: Any]? = nil) {
        // Send the event to Firebase Analytics or other platforms
        Analytics.logEvent(eventName, parameters: parameters)
        
        // Optional: Handle custom event logging, if needed (e.g., for internal tracking or debugging)
        print("Logged event: \(eventName) with parameters: \(String(describing: parameters))")
    }
    
    // Example of tracking user properties
    func setUserProperty(value: String, forKey key: String) {
        // Set custom user properties (can be used to segment users)
        Analytics.setUserProperty(value, forName: key)
        print("Set user property: \(key) = \(value)")
    }
    
    // Example: Track app lifecycle events
    func logAppLaunch() {
        logEvent(eventName: "app_launch")
    }
    
    func logScreenView(screenName: String) {
        logEvent(eventName: "screen_view", parameters: ["screen_name": screenName])
    }
    
    func logUserAction(action: String, details: [String: Any]) {
        logEvent(eventName: "user_action", parameters: ["action": action] + details)
    }
}

// Track app launch
AnalyticsManager.shared.logAppLaunch()

// Track a screen view event
AnalyticsManager.shared.logScreenView(screenName: "Home")

// Track a user action (e.g., button tap)
AnalyticsManager.shared.logUserAction(action: "tap_button", details: ["button_name": "login_button"])

// Set a user property
AnalyticsManager.shared.setUserProperty(value: "premium_user", forKey: "user_status")
