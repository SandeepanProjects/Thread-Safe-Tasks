//
//  OAuth.swift
//  
//
//  Created by Apple on 06/04/25.
//

import Foundation
To implement **OAuth** in iOS SwiftUI, you can use **AuthenticationServices** or third-party libraries like **OAuthSwift**. Here's a step-by-step guide:

---

### 1. **Set Up Your OAuth Provider**
   - Register your app with the OAuth provider (e.g., Google, Facebook, Spotify).
   - Obtain the **client ID**, **client secret**, and **redirect URI**.

---

### 2. **Use ASWebAuthenticationSession**
   Apple's **AuthenticationServices** framework provides `ASWebAuthenticationSession` for handling OAuth flows. Here's an example:

#### Example Code:
```swift
import AuthenticationServices
import SwiftUI

struct OAuthView: View {
    var body: some View {
        Button("Login with OAuth") {
            startOAuthFlow()
        }
    }
    
    func startOAuthFlow() {
        let authURL = URL(string: "https://example.com/oauth/authorize?client_id=YOUR_CLIENT_ID&redirect_uri=YOUR_REDIRECT_URI&response_type=code")!
        let callbackURLScheme = "yourapp"
        
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackURLScheme) { callbackURL, error in
            if let callbackURL = callbackURL {
                // Extract the authorization code from the callback URL
                let queryItems = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?.queryItems
                let code = queryItems?.first(where: { $0.name == "code" })?.value
                print("Authorization Code: \(code ?? "No code")")
            } else if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
        session.presentationContextProvider = self
        session.start()
    }
}

extension OAuthView: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
}
```

---

### 3. **Exchange Authorization Code for Access Token**
   After obtaining the authorization code, send a POST request to the OAuth provider's token endpoint to exchange it for an access token:

#### Example Code:
```swift
func exchangeCodeForToken(code: String) {
    let tokenURL = URL(string: "https://example.com/oauth/token")!
    var request = URLRequest(url: tokenURL)
    request.httpMethod = "POST"
    let body = "client_id=YOUR_CLIENT_ID&client_secret=YOUR_CLIENT_SECRET&code=\(code)&redirect_uri=YOUR_REDIRECT_URI&grant_type=authorization_code"
    request.httpBody = body.data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let data = data {
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            print("Access Token Response: \(json ?? "No response")")
        } else if let error = error {
            print("Error: \(error.localizedDescription)")
        }
    }.resume()
}
```

---

### 4. **Store and Use Access Token**
   - Save the access token securely using **Keychain**.
   - Use the token to make authenticated API requests.

---

### 5. **Third-Party Libraries**
   If you prefer using a library, **OAuthSwift** simplifies the process. You can find more details [here](https://github.com/OAuthSwift/OAuthSwift).

---
