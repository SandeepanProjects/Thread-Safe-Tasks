//
//  Opaque Types Generics.swift
//  
//
//  Created by Apple on 05/04/25.
//

Opaque Types: You hide the concrete type and only specify the type’s behavior (via protocol conformance or other constraints). The caller doesn’t know the exact type at compile time.
Generics: The concrete type is known at compile time. The caller knows exactly what type is being used and it’s specified as a type parameter (T).

protocol Animal {
    func makeSound() -> String
}

struct Dog: Animal {
    func makeSound() -> String {
        return "Woof!"
    }
}

struct Cat: Animal {
    func makeSound() -> String {
        return "Meow!"
    }
}

func createAnimal() -> some Animal {
    return Dog()
}

func getAnimal() -> some Animal {
    return Dog()  // Here Dog is returned, but we don't expose the concrete type
}

let animal = getAnimal()
print(animal.makeSound())  // Prints "Woof!", but we don't know it's a Dog


Generics:

func printValue<T>(value: T) {
    print(value)
}

printValue(value: 42)  // Prints "42"
printValue(value: "Hello")  // Prints "Hello"


func printShape<T: Shape>(shape: T) {
    print(shape.draw())
}

you are accepting any type that conforms to the Shape protocol, but the caller knows exactly what type T is when they call printShape()
