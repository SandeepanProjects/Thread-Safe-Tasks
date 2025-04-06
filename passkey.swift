//
//  passkey.swift
//  
//
//  Created by Apple on 06/04/25.
//

Implementing **passkeys** in iOS SwiftUI involves using **AuthenticationServices** to enable passwordless authentication. Passkeys rely on public-private key pairs stored securely in iCloud Keychain, allowing users to authenticate with biometrics like Face ID or Touch ID.

### Steps to Implement Passkeys in SwiftUI

#### 1. **Enable Associated Domains**
   - In your Xcode project, go to **Signing & Capabilities**.
   - Add the **Associated Domains** capability.
   - Specify your domain with the `webcredentials` service (e.g., `webcredentials:example.com`).
   - Ensure your server has an `apple-app-site-association` (AASA) file in the `.well-known` directory.

#### 2. **Set Up AuthenticationServices**
   Use `ASAuthorizationController` to handle passkey registration and authentication.

#### Example Code for Passkey Registration:
```swift
import AuthenticationServices
import SwiftUI

struct PasskeyView: View {
    var body: some View {
        Button("Register Passkey") {
            registerPasskey()
        }
    }
    
    func registerPasskey() {
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "example.com")
        let request = provider.createCredentialRegistrationRequest(challenge: Data())
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = PasskeyDelegate()
        controller.performRequests()
    }
}

class PasskeyDelegate: NSObject, ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredential {
            print("Passkey registered: \(credential)")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
```

#### 3. **Authenticate Using Passkeys**
   For authentication, create a request using the same `ASAuthorizationPlatformPublicKeyCredentialProvider`:

```swift
func authenticateWithPasskey() {
    let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "example.com")
    let request = provider.createCredentialAssertionRequest(challenge: Data())
    
    let controller = ASAuthorizationController(authorizationRequests: [request])
    controller.delegate = PasskeyDelegate()
    controller.performRequests()
}
```

#### 4. **Server-Side Integration**
   - Your server must support **WebAuthn** for passkey registration and authentication.
   - Use the challenge provided by the server during registration and authentication.
   - Verify the response from the client using WebAuthn libraries.

#### 5. **Testing**
   - Test passkey functionality on devices running iOS 16 or later.
   - Ensure your server and app configurations align with Apple's requirements.

You can find more details in Apple's [documentation](https://developer.apple.com/documentation/authenticationservices/connecting_to_a_service_with_passkeys) and [guides](https://developer.apple.com/documentation/AuthenticationServices/supporting-passkeys). Let me know if you'd like help with specific parts of the implementation! 🚀

