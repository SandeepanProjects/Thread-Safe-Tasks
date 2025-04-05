//
//  Stripe’s PaymentSheet.swift
//  
//
//  Created by Apple on 05/04/25.
//

Implementing a payment gateway in an iOS app using SwiftUI involves several steps. You can integrate payment gateways like Stripe, PayPal, or Apple Pay, depending on your needs. Below, I'll guide you through a simple example using **Stripe**, which is one of the most popular and widely used payment gateways.

### Steps to Implement Stripe Payment Gateway in iOS with SwiftUI

1. **Create a Stripe Account**
   - Go to [Stripe](https://stripe.com) and create an account if you don’t have one already.
   - Get your API keys (both test and live keys) from the Stripe dashboard.

2. **Install Stripe SDK**
   - The first step is to add Stripe SDK to your project using Swift Package Manager or CocoaPods. Here's how to do it with Swift Package Manager:

   - Open your Xcode project.
   - Go to **File** > **Add Packages**.
   - Search for `https://github.com/stripe/stripe-ios.git` and select it.
   - Choose the version you need (typically the latest stable release).

3. **Set up a Backend**
   - Stripe requires a backend server to generate **Payment Intents** and handle secure communication with Stripe’s API. You need to set up a backend (Node.js, Ruby, Python, etc.) to handle creating and confirming payments.
   - Your backend will interact with the Stripe API to create Payment Intents, retrieve client secrets, etc.

   For simplicity, you can use the **Stripe example backend** or use a service like Firebase functions.

4. **Set Up Apple Pay (Optional)**
   - You can integrate Apple Pay if you'd like to offer users a native payment experience.
   - You need to register for Apple Pay on your Apple Developer account and set it up in your app.

5. **SwiftUI Payment Integration (Front-end)**

   1. **Import Stripe SDK**
      In your SwiftUI view or App file, import the Stripe SDK:
      ```swift
      import Stripe
      ```

   2. **Create a Payment Intent**
      Before proceeding with the payment in your app, you need to create a PaymentIntent object on the backend, which provides a client secret to authorize the transaction.
      - In your backend, implement an endpoint like `/create-payment-intent` that interacts with the Stripe API to create a PaymentIntent and returns the `client_secret`.

      Example backend code (Node.js):
      ```javascript
      const stripe = require('stripe')(YOUR_STRIPE_SECRET_KEY);

      app.post('/create-payment-intent', async (req, res) => {
          const paymentIntent = await stripe.paymentIntents.create({
              amount: 1000, // The amount in the smallest currency unit (e.g., cents)
              currency: 'usd',
          });

          res.send({
              clientSecret: paymentIntent.client_secret,
          });
      });
      ```

   3. **Configure PaymentView in SwiftUI**
      Now, set up the Stripe Payment request flow on your front end.

      1. **Create a Payment Configuration**
         Configure Stripe to handle the payment method and client secret.

         ```swift
         import Stripe

         struct PaymentView: View {
             @State private var paymentMethodParams: STPPaymentMethodParams?
             @State private var clientSecret: String?
             @State private var isProcessing = false

             var body: some View {
                 VStack {
                     if let clientSecret = clientSecret {
                         PaymentSheetView(clientSecret: clientSecret)
                     } else {
                         Text("Loading payment details...")
                             .onAppear {
                                 fetchPaymentIntent()
                             }
                     }
                 }
             }

             private func fetchPaymentIntent() {
                 // Call your backend to fetch the client secret
                 // Assume the backend returns a response with the client secret
                 let url = URL(string: "https://your-backend-url/create-payment-intent")!
                 var request = URLRequest(url: url)
                 request.httpMethod = "POST"
                 let task = URLSession.shared.dataTask(with: request) { data, response, error in
                     if let data = data {
                         do {
                             let response = try JSONDecoder().decode([String: String].self, from: data)
                             self.clientSecret = response["clientSecret"]
                         } catch {
                             print("Failed to parse client secret")
                         }
                     }
                 }
                 task.resume()
             }
         }
         ```

   4. **Create the PaymentSheet View**
      Stripe has a **PaymentSheet** that handles the entire user flow for the payment. It simplifies the process of gathering payment details and completing the transaction.

      ```swift
      struct PaymentSheetView: View {
          let clientSecret: String
          @State private var isPresentingPaymentSheet = false
          @State private var paymentResult: PaymentSheetResult?

          var body: some View {
              VStack {
                  Button("Pay") {
                      startPaymentFlow()
                  }
                  .padding()
                  .alert(item: $paymentResult) { result in
                      switch result {
                      case .completed:
                          return Alert(title: Text("Payment successful"))
                      case .failed(let error):
                          return Alert(title: Text("Payment failed"), message: Text(error.localizedDescription))
                      }
                      return Alert(title: Text("Unknown error"))
                  }
              }
              .onAppear {
                  configurePaymentSheet()
              }
          }

          private func configurePaymentSheet() {
              var configuration = PaymentSheet.Configuration()
              configuration.merchantDisplayName = "Your Business Name"
              let paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
              self.paymentSheet = paymentSheet
          }

          private func startPaymentFlow() {
              paymentSheet.present(from: self) { paymentResult in
                  switch paymentResult {
                  case .completed:
                      self.paymentResult = .completed
                  case .failed(let error):
                      self.paymentResult = .failed(error)
                  case .canceled:
                      self.paymentResult = .failed(NSError(domain: "Canceled", code: 0, userInfo: nil))
                  }
              }
          }
      }
      ```

   5. **Handle the Payment Completion**
      Stripe's PaymentSheet automatically handles the completion process and will call the appropriate callback with the payment result. You can display the appropriate message (success or failure) to the user.

6. **Test the Payment Flow**
   - Use the test keys provided by Stripe and test the payment flow.
   - Stripe provides test card numbers that you can use for testing payments without actually making a charge.

7. **Go Live**
   - Once everything works as expected in test mode, switch to your live API keys and test again.

### Notes:
- Make sure to handle errors (network issues, Stripe failures) gracefully in your app.
- Use the appropriate API version and check Stripe’s documentation for any changes or updates.
- You can also add additional features like saving cards, adding support for Apple Pay, etc.

### Resources:
- [Stripe iOS SDK documentation](https://stripe.com/docs/payments/accept-a-payment?platform=ios)
- [Apple Pay documentation](https://developer.apple.com/documentation/passkit)

This is a basic setup using Stripe’s PaymentSheet, which handles a lot of the heavy lifting. You can expand this integration to include more payment methods, custom UIs, and more!
