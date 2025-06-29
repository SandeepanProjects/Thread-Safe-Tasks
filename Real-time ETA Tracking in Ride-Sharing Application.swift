//
//  Real-time ETA Tracking in Ride-Sharing Application.swift
//  
//
//  Created by Apple on 07/06/25.
//

import Foundation

[![GitHub - hypertrack/ridesharing-ios ...](https://images.openai.com/thumbnails/b8a8e45e510dfa6a8c5b9a43a7f60f87.jpeg)](https://github.com/hypertrack/ridesharing-ios)

Implementing real-time Estimated Time of Arrival (ETA) tracking in a ride-sharing application using SwiftUI involves several key components:

---

## 🛠 Core Components

1. **MapKit**: For displaying maps and handling geospatial data.
2. **Core Location**: To access and manage the user's current location.
3. **Google Maps Directions API**: To calculate ETAs based on real-time traffic and routing.
4. **Firebase Realtime Database**: For real-time data synchronization between the driver and rider.
5. **Live Activities**: To provide real-time updates on the lock screen or Dynamic Island.

---

## 📍 Step-by-Step Implementation

### 1. **Set Up Location Services**

First, ensure your app has the necessary permissions to access location data. Add the following keys to your `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show your position on the map.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to track your ride in real-time.</string>
```

Next, create a `LocationManager` class to handle location updates:

```swift
import CoreLocation
import Combine

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager = CLLocationManager()
    @Published var location: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        location = newLocation
    }
}
```

---

### 2. **Integrate MapKit for Map Display**

In your SwiftUI view, use `MapKit` to display the user's location and the driver's location:

```swift
import SwiftUI
import MapKit

struct RideTrackingView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var driverLocation: CLLocationCoordinate2D?
    @State private var eta: String = "Calculating..."

    var body: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )), showsUserLocation: true, userTrackingMode: .follow)
            .onAppear {
                fetchDriverLocation()
                calculateETA()
            }
    }

    private func fetchDriverLocation() {
        // Fetch the driver's location from Firebase or your backend
        // Update driverLocation with the fetched coordinates
    }

    private func calculateETA() {
        guard let userLocation = locationManager.location?.coordinate, let driverLocation = driverLocation else { return }

        let origin = "\(userLocation.latitude),\(userLocation.longitude)"
        let destination = "\(driverLocation.latitude),\(driverLocation.longitude)"
        let apiKey = "YOUR_GOOGLE_MAPS_API_KEY"
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&key=\(apiKey)"

        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(GoogleMapsDirectionsResponse.self, from: data)
                if let duration = response.routes.first?.legs.first?.duration.text {
                    DispatchQueue.main.async {
                        self.eta = duration
                    }
                }
            } catch {
                print("Error decoding ETA response: \(error)")
            }
        }
        task.resume()
    }
}
```

Define the necessary structs to decode the Google Maps Directions API response:

```swift
struct GoogleMapsDirectionsResponse: Codable {
    let routes: [Route]
}

struct Route: Codable {
    let legs: [Leg]
}

struct Leg: Codable {
    let duration: Duration
}

struct Duration: Codable {
    let text: String
}
```

---

### 3. **Implement Real-Time Updates with Firebase**

Set up Firebase in your project and configure real-time listeners to update the driver's location:

```swift
import Firebase
import FirebaseDatabase

class RideManager: ObservableObject {
    private var ref: DatabaseReference!
    @Published var driverLocation: CLLocationCoordinate2D?

    init() {
        ref = Database.database().reference()
        observeDriverLocation()
    }

    private func observeDriverLocation() {
        ref.child("driverLocation").observe(.value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let lat = value["latitude"] as? CLLocationDegrees,
                  let lon = value["longitude"] as? CLLocationDegrees else { return }

            DispatchQueue.main.async {
                self.driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
        }
    }
}
```

In your `RideTrackingView`, observe the `RideManager` to get real-time updates:

```swift
@StateObject private var rideManager = RideManager()

var body: some View {
    Map(coordinateRegion: .constant(MKCoordinateRegion(
        center: rideManager.driverLocation ?? CLLocationCoordinate2D(),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )), showsUserLocation: true, userTrackingMode: .follow)
}
```

---

### 4. **Enhance User Experience with Live Activities**

To provide real-time updates on the lock screen or Dynamic Island, implement Live Activities using WidgetKit. This allows users to track their ride without opening the app. For a detailed guide on implementing Live Activities, refer to the tutorial on creating a basic live activity for an Uber-like app .

---

## 📚 Additional Resources

* [GitHub - hypertrack/ridesharing-ios](https://github.com/hypertrack/ridesharing-ios): A sample project demonstrating ride-sharing app features.
* [Using Google Maps to Update your Customers with Accurate ETAs](https://afi.io/blog/using-the-google-maps-api-to-get-driver-etas/): A blog post detailing how to use the Google Maps API for ETA calculations.
* [Real-time GPS Tracking for Fleet Management in SwiftUI](https://peerdh.com/blogs/programming-insights/real-time-gps-tracking-for-fleet-management-in-swiftui): A guide on implementing real-time GPS tracking in SwiftUI.

---

If you need assistance with specific aspects, such as integrating Google Maps SDK, setting up Firebase, or implementing Live Activities, feel free to ask!
