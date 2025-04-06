//
//  Liskov Substitution Principle.swift
//  
//
//  Created by Apple on 06/04/25.
//

import Foundation

objects of a superclass should be replaceable with objects of a subclass without affecting the behavior of the program

class Shape {
    func area() -> Double {
        return 0.0
    }
}

class Rectangle: Shape {
    var width: Double
    var height: Double
    
    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    override func area() -> Double {
        return width * height
    }
}

class Circle: Shape {
    var radius: Double
    
    init(radius: Double) {
        self.radius = radius
    }
    
    override func area() -> Double {
        return Double.pi * radius * radius
    }
}

// Usage
let shapes: [Shape] = [Rectangle(width: 10, height: 5), Circle(radius: 7)]
for shape in shapes {
    print("Area: \(shape.area())")
}


Violating LSP

class Rectangle: Shape {
    var width: Double
    var height: Double
    
    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    override func area() -> Double {
        // Violation: Changes behavior unexpectedly for some shapes
        if width == height {
            return width * width
        }
        return width * height
    }
}

This violates LSP because the subclass behavior isn't consistent with the superclass contract. When Rectangle is substituted for Shape, it introduces logic that may break expectations, leading to unpredictable results.
