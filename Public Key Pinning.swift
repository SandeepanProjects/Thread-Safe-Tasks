//
//  Public Key Pinning.swift
//  
//
//  Created by Apple on 06/04/25.
//

Implementing **public key pinning** for SSL in iOS using Swift enhances app security by preventing **man-in-the-middle (MITM) attacks**. Public key pinning ensures that your app only trusts specific public keys, even if the certificate authority is compromised.

### Steps to Implement Public Key Pinning

#### 1. **Extract Public Key**
   - Use OpenSSL to extract the public key from the server's certificate:
     ```bash
     openssl s_client -connect yourdomain.com:443 -showcerts < /dev/null | openssl x509 -pubkey -noout > publickey.pem
     ```
   - Convert the PEM file to DER format:
     ```bash
     openssl x509 -in publickey.pem -inform PEM -out publickey.der -outform DER
     ```

#### 2. **Add Public Key to Your App**
   - Include the `.der` file in your app's bundle.
   - Ensure it's listed in the **Copy Bundle Resources** section of your Xcode project.

#### 3. **Implement URLSessionDelegate**
   - Create a custom delegate to validate the server's public key during SSL handshake:

```swift
import Foundation

class SSLPinningDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            let serverPublicKey = SecCertificateCopyKey(serverCertificate)
            let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil) as Data
            
            if let localPublicKeyPath = Bundle.main.path(forResource: "publickey", ofType: "der"),
               let localPublicKeyData = try? Data(contentsOf: URL(fileURLWithPath: localPublicKeyPath)) {
                if serverPublicKeyData == localPublicKeyData {
                    completionHandler(.useCredential, URLCredential(trust: serverTrust))
                    return
                }
            }
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
```

#### 4. **Use the Delegate in URLSession**
   - Create a session with your custom delegate:

```swift
let session = URLSession(configuration: .default, delegate: SSLPinningDelegate(), delegateQueue: nil)
if let url = URL(string: "https://yourdomain.com") {
    let task = session.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
        } else {
            print("Data received: \(data?.count ?? 0) bytes")
        }
    }
    task.resume()
}
```

#### 5. **Test Your Implementation**
   - Verify that your app rejects connections to servers without the pinned public key.
   - Use tools like **Charles Proxy** to simulate MITM attacks and ensure your app blocks them.

### Key Considerations
- **Backup Keys**: Include backup public keys to handle server key rotation without breaking your app.
- **Performance**: Public key pinning adds overhead during SSL handshake; ensure it doesn't impact user experience.
- **Updates**: Regularly update pinned keys to avoid disruptions when certificates change.
