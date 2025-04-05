//
//  chat app.swift
//  
//
//  Created by Apple on 05/04/25.
//

To create a chat app in SwiftUI using WebSockets for real-time communication, you'll need to connect to a WebSocket server and handle sending and receiving messages.

Here’s a step-by-step guide for setting up WebSockets in a SwiftUI chat app using **`URLSessionWebSocketTask`** in Swift 5 and later. This will allow you to maintain a real-time connection between the iOS client and your WebSocket server.

### 1. **Create a WebSocket Manager**
First, you need a WebSocket manager to handle the connection to the WebSocket server.

```swift
import Foundation

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let url = URL(string: "ws://your-websocket-server-url")!  // Replace with your server URL
    @Published var messages: [String] = []
    
    init() {
        connect()
    }
    
    // Connect to WebSocket server
    func connect() {
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // Start listening for messages
        receiveMessage()
    }
    
    // Send message to WebSocket server
    func sendMessage(message: String) {
        let messageToSend = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(messageToSend) { error in
            if let error = error {
                print("Error sending message: \(error)")
            }
        }
    }
    
    // Receive message from WebSocket server
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Failed to receive message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self?.messages.append(text)
                    }
                case .data(let data):
                    // Handle binary data if needed
                    print("Received binary data: \(data)")
                @unknown default:
                    print("Unknown message type")
                }
            }
            
            // Continue listening
            self?.receiveMessage()
        }
    }
    
    // Close the WebSocket connection
    func closeConnection() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
```

### 2. **Create the SwiftUI View**
Now, let’s create a simple SwiftUI view that interacts with this `WebSocketManager`. It will display the messages and allow the user to send a message.

```swift
import SwiftUI

struct ChatView: View {
    @StateObject private var webSocketManager = WebSocketManager()
    @State private var newMessage = ""
    
    var body: some View {
        VStack {
            // Display messages from WebSocket
            ScrollView {
                ForEach(webSocketManager.messages, id: \.self) { message in
                    Text(message)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.bottom, 4)
                }
            }
            
            // Text field to enter message
            HStack {
                TextField("Enter message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    if !newMessage.isEmpty {
                        webSocketManager.sendMessage(message: newMessage)
                        newMessage = ""
                    }
                }) {
                    Text("Send")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.bottom)
        }
        .onDisappear {
            webSocketManager.closeConnection()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
```

### 3. **Handling WebSocket Connection**
- When the `ChatView` appears, it will connect to the WebSocket server automatically through the `WebSocketManager` initializer.
- It listens for incoming messages and updates the view when new messages arrive.
- The user can send messages by typing in the text field and tapping the send button.

### 4. **Running the App**
To test the WebSocket functionality, you will need a WebSocket server running that the app can connect to. For local testing, you can use a WebSocket server like [Socket.IO](https://socket.io/) or any other WebSocket server implementation.

For example, with a WebSocket server running on `ws://localhost:8080`, replace `"ws://your-websocket-server-url"` in the `WebSocketManager` with your actual WebSocket server URL.

### 5. **WebSocket Server Example (Optional)**
Here’s a quick example of how you might set up a WebSocket server in **Node.js** using the `ws` library:

```bash
npm init -y
npm install ws
```

Then, create a simple WebSocket server:

```javascript
const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8080 });

wss.on('connection', (ws) => {
    console.log('A new client connected');
    ws.on('message', (message) => {
        console.log(`Received: ${message}`);
        // Broadcast message to all clients
        wss.clients.forEach((client) => {
            if (client !== ws && client.readyState === WebSocket.OPEN) {
                client.send(message);
            }
        });
    });
    ws.send('Welcome to the WebSocket server');
});
```

### 6. **Important Notes**
- **WebSocket Protocol:** Ensure that the WebSocket URL begins with `ws://` or `wss://` (secure WebSocket).
- **Error Handling:** Consider adding more robust error handling and reconnection logic for production applications.
- **Secure WebSocket (wss):** If deploying to production, always use `wss://` instead of `ws://` for secure communication.

With this setup, you should be able to create a real-time chat application in SwiftUI using WebSockets!
