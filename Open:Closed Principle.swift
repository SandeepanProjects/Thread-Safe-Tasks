//
//  Open:Closed Principle.swift
//  
//
//  Created by Apple on 06/04/25.
//

import Foundation

Let's say you have a payment system, and you want to support multiple payment methods (e.g., Credit Card, PayPal).

protocol PaymentProcessor {
    func processPayment(amount: Double)
}

class CreditCardPayment: PaymentProcessor {
    func processPayment(amount: Double) {
        print("Processing credit card payment of \(amount)")
    }
}

class PayPalPayment: PaymentProcessor {
    func processPayment(amount: Double) {
        print("Processing PayPal payment of \(amount)")
    }
}

// Usage
func performPayment(processor: PaymentProcessor, amount: Double) {
    processor.processPayment(amount: amount)
}

let paymentMethod = CreditCardPayment()
performPayment(processor: paymentMethod, amount: 100.0)

Adding a new payment type (e.g., Apple Pay) simply requires creating a new class conforming to PaymentProcessor.
You don’t need to modify the existing performPayment function, adhering to the closed for modification rule.


Using Inheritance
                                                                                            
class Logger {
    func log(message: String) {
        // Base logging functionality
        print("Log: \(message)")
    }
}

class FileLogger: Logger {
    override func log(message: String) {
        // Extended functionality for file logging
        print("Writing log to file: \(message)")
    }
}

class ConsoleLogger: Logger {
    override func log(message: String) {
        // Extended functionality for console logging
        print("Writing log to console: \(message)")
    }
}

// Usage
let logger = FileLogger()
logger.log(message: "App started!")

base Logger class is closed for modification since it remains unchanged.
New behaviors like file logging or console logging can be added by extending the class.



how to violate ocp
                                    
func performPayment(processor: PaymentProcessor, amount: Double) {
    if processor is CreditCardPayment {
        print("Processing credit card payment of \(amount)")
    } else if processor is PayPalPayment {
        print("Processing PayPal payment of \(amount)")
    } else {
        print("Unsupported payment method")
    }
}

The performPayment function is no longer closed for modification. If you add a new payment type (e.g., Apple Pay), you must modify this function by introducing another conditional block for the new type.
This introduces tight coupling and reduces scalability, making the code harder to maintain over time.
