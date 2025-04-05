//
//  Apple Pay integration using Stripe.swift
//  
//
//  Created by Apple on 05/04/25.
//

To integrate **Stripe** with **Apple Pay** in an iOS app using **SwiftUI**, the process involves several steps, including setting up your Stripe account, configuring Apple Pay, and implementing the payment flow in your app. Here’s a step-by-step guide on how to implement Stripe with Apple Pay:

### Prerequisites:
1. **Stripe Account**: You need to have a Stripe account. If you don’t have one, create it on the [Stripe website](https://stripe.com).
2. **Apple Developer Account**: To implement Apple Pay, you need an Apple Developer account, which you can get at [Apple Developer](https://developer.apple.com/).
3. **Stripe API Keys**: Obtain your **publishable key** (for the frontend) and **secret key** (for the backend) from the Stripe dashboard.

### Steps to Implement Stripe with Apple Pay:

#### 1. **Set Up Your Apple Developer Account for Apple Pay**
   - Sign in to your Apple Developer account.
   - In **Certificates, Identifiers & Profiles**, go to **Identifiers**, then select your app.
   - Under **Capabilities**, enable **Apple Pay**.
   - Make sure that your app’s bundle identifier matches the one you use in your Xcode project.

#### 2. **Enable Apple Pay in Xcode**
   - In your Xcode project, go to your app’s **target**.
   - Under **Signing & Capabilities**, click the **+** button and add the **Apple Pay** capability.
   - This ensures that your app can communicate with Apple Pay APIs.

#### 3. **Configure Your Stripe Account for Apple Pay**
   - In your **Stripe Dashboard**, navigate to the **Apple Pay** section under **Settings**.
   - You’ll need to verify your domain to use Apple Pay with your Stripe account.
   - Once the domain is verified, ensure that the **Apple Pay** option is enabled for your account.

#### 4. **Add Stripe SDK to Your Project**
   First, add the **Stripe iOS SDK** to your project. You can do this using **Swift Package Manager** (recommended), or **CocoaPods**.

   **Swift Package Manager**:
   - Go to **File > Add Packages** in Xcode.
   - Search for `https://github.com/stripe/stripe-ios.git` and select the package.

#### 5. **Backend Setup**
   Your backend server is required to create a **PaymentIntent** or **SetupIntent** with Stripe, which is needed to securely handle payments. The backend will also need to confirm the payment.

   Here’s a basic backend setup in Node.js for creating a **PaymentIntent**:

   ```javascript
   const stripe = require('stripe')('sk_test_yourSecretKey');

   app.post('/create-payment-intent', async (req, res) => {
     const { amount } = req.body;

     const paymentIntent = await stripe.paymentIntents.create({
       amount: amount,
       currency: 'usd',
       payment_method_types: ['card', 'apple_pay'], // Supports Apple Pay
     });

     res.send({
       clientSecret: paymentIntent.client_secret,
     });
   });
   ```

   Your backend will send back the `clientSecret` which is used in the next step to complete the payment.

#### 6. **Configure Stripe with Apple Pay in SwiftUI**

   1. **Import Stripe SDK**:

      In your SwiftUI view or App file, import the Stripe SDK:
      ```swift
      import Stripe
      ```

   2. **Configure Payment Request**:
      Set up the Apple Pay button and create a payment request in your SwiftUI view.

      ```swift
      struct PaymentView: View {
          @State private var paymentResult: PaymentSheetResult?
          @State private var clientSecret: String?
          @State private var isPresentingPaymentSheet = false

          var body: some View {
              VStack {
                  if let clientSecret = clientSecret {
                      Button("Pay with Apple Pay") {
                          startApplePayPaymentFlow()
                      }
                      .padding()
                      .alert(item: $paymentResult) { result in
                          switch result {
                          case .completed:
                              return Alert(title: Text("Payment Successful"))
                          case .failed(let error):
                              return Alert(title: Text("Payment Failed"), message: Text(error.localizedDescription))
                          case .canceled:
                              return Alert(title: Text("Payment Canceled"))
                          }
                      }
                  } else {
                      Text("Loading payment details...")
                          .onAppear {
                              fetchPaymentIntent()
                          }
                  }
              }
          }

          private func fetchPaymentIntent() {
              // Call your backend to fetch the PaymentIntent client secret
              let url = URL(string: "https://your-backend-url/create-payment-intent")!
              var request = URLRequest(url: url)
              request.httpMethod = "POST"
              let task = URLSession.shared.dataTask(with: request) { data, response, error in
                  if let data = data {
                      do {
                          let response = try JSONDecoder().decode([String: String].self, from: data)
                          self.clientSecret = response["clientSecret"]
                      } catch {
                          print("Error decoding payment intent response.")
                      }
                  }
              }
              task.resume()
          }

          private func startApplePayPaymentFlow() {
              // Create PaymentSheet configuration
              var configuration = PaymentSheet.Configuration()
              configuration.merchantDisplayName = "Your Business Name"
              configuration.applePay = .init(
                  merchantIdentifier: "merchant.com.yourcompany",
                  merchantCountryCode: "US"
              )

              // Initialize Stripe PaymentSheet with the client secret
              let paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret!, configuration: configuration)
              paymentSheet.present(from: UIApplication.shared.windows.first!.rootViewController!) { paymentResult in
                  switch paymentResult {
                  case .completed:
                      self.paymentResult = .completed
                  case .failed(let error):
                      self.paymentResult = .failed(error)
                  case .canceled:
                      self.paymentResult = .failed(NSError(domain: "Payment Canceled", code: 0, userInfo: nil))
                  }
              }
          }
      }
      ```

   3. **Implement the Payment Flow**:
      When the user presses the **Pay with Apple Pay** button, Stripe’s `PaymentSheet` will handle the entire Apple Pay flow for you. It will manage the payment sheet presentation, user authentication, and payment confirmation.

   **Key Steps**:
   - **Backend** creates a **PaymentIntent** and returns the `clientSecret` to your app.
   - **PaymentSheet** uses that `clientSecret` to process the payment.
   - Apple Pay processes the payment, and the result is returned, including success or failure.

#### 7. **Test Apple Pay in Your App**
   - To test Apple Pay, ensure you have a valid **Apple Pay account** configured on a real device (Apple Pay doesn’t work in simulators).
   - Test the flow using **Stripe’s test environment** and test credit cards from Stripe documentation.
   - Apple Pay works only with **real devices** and requires a valid Apple Pay account to complete the transaction.

#### 8. **Go Live**
   - Once you’ve confirmed everything works in test mode, switch your keys to the live API keys from Stripe and test again.

### Summary of the Key Points:
1. Set up **Apple Pay** and configure it in your **Apple Developer account**.
2. Configure your app for **Apple Pay** in Xcode.
3. Set up your **Stripe** account to handle **Apple Pay**.
4. In your app, use **Stripe SDK** and the **PaymentSheet** to handle payments with **Apple Pay**.
5. Ensure your backend creates the **PaymentIntent** and returns the client secret.

### Resources:
- [Stripe iOS SDK Documentation](https://stripe.com/docs/payments/accept-a-payment?platform=ios)
- [Apple Pay Developer Documentation](https://developer.apple.com/documentation/passkit/apple_pay)

By following these steps, you’ll have a working Apple Pay integration using Stripe in your iOS app. Let me know if you need further clarification or assistance with any part of the implementation!
