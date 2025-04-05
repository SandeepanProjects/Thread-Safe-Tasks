//
//  TypeErasure.swift
//  
//
//  Created by Apple on 05/04/25.
//

Type erasure in Swift is useful in real-world scenarios, especially when dealing with protocols, generics, and abstracting away the underlying implementation details. Here are some practical examples to help illustrate when and why you might use type erasure in a real-world context:

### 1. **Networking Layer with Response Handling**

In a networking layer, you might define a protocol for handling responses:

```swift
protocol NetworkResponseHandler {
    associatedtype Response
    func handleResponse(_ response: Response)
}
```

You could have multiple types of responses, like `JSONResponse`, `XMLResponse`, or `ImageResponse`, each having its own concrete implementation of `handleResponse`. However, you can't use `NetworkResponseHandler` directly because of the associated type. Here, you can use type erasure to handle this:

```swift
// Type Erasure Wrapper
class AnyNetworkResponseHandler<T>: NetworkResponseHandler {
    private let _handleResponse: (T) -> Void
    
    init<U: NetworkResponseHandler>(_ handler: U) where U.Response == T {
        _handleResponse = handler.handleResponse
    }
    
    func handleResponse(_ response: T) {
        _handleResponse(response)
    }
}
```

Now, you can store different types of `NetworkResponseHandler` in a collection and call `handleResponse` without needing to know the concrete types.

```swift
let jsonHandler: AnyNetworkResponseHandler<JSONResponse> = AnyNetworkResponseHandler(JSONHandler())
let xmlHandler: AnyNetworkResponseHandler<XMLResponse> = AnyNetworkResponseHandler(XMLHandler())

let handlers: [AnyNetworkResponseHandler<Any>] = [jsonHandler, xmlHandler]
```

### 2. **Event Handling System**

Imagine you have an event handling system where different event types conform to a protocol, and you need to store them in a collection to be processed later. The protocol might look like this:

```swift
protocol Event {
    func process()
}

struct UserLoginEvent: Event {
    func process() {
        print("User logged in.")
    }
}

struct ButtonClickEvent: Event {
    func process() {
        print("Button clicked.")
    }
}
```

You could store all of these `Event` objects in a collection, but since you can't directly use `Event` with its associated types, you can create a type-erased wrapper:

```swift
class AnyEvent: Event {
    private let _process: () -> Void
    
    init<E: Event>(_ event: E) {
        _process = event.process
    }
    
    func process() {
        _process()
    }
}
```

Now you can store different types of `Event` objects (such as `UserLoginEvent`, `ButtonClickEvent`) in an array:

```swift
let events: [AnyEvent] = [
    AnyEvent(UserLoginEvent()),
    AnyEvent(ButtonClickEvent())
]

for event in events {
    event.process()  // Outputs the corresponding event's process logic
}
```

### 3. **Custom SwiftUI Views with Different Content Types**

In SwiftUI, you might want to create a custom view that can accept multiple types of content views. However, SwiftUI uses generics and requires you to specify exact types. Type erasure can be helpful to create a view that can accept various types of content while maintaining flexibility.

Let's say you want to build a custom `CardView` that can accept multiple types of content, like a `Text` or an `Image`:

```swift
protocol CardContent {
    func bodyContent() -> AnyView
}

struct TextContent: CardContent {
    let text: String
    
    func bodyContent() -> AnyView {
        AnyView(Text(text))
    }
}

struct ImageContent: CardContent {
    let imageName: String
    
    func bodyContent() -> AnyView {
        AnyView(Image(systemName: imageName))
    }
}
```

Using type erasure (`AnyCardContent`), you can store different types of `CardContent` views:

```swift
class AnyCardContent: CardContent {
    private let _bodyContent: () -> AnyView
    
    init<C: CardContent>(_ content: C) {
        _bodyContent = content.bodyContent
    }
    
    func bodyContent() -> AnyView {
        _bodyContent()
    }
}
```

Now, you can store different types of `CardContent` (e.g., `TextContent`, `ImageContent`) in a list:

```swift
let cardContents: [AnyCardContent] = [
    AnyCardContent(TextContent(text: "Welcome")),
    AnyCardContent(ImageContent(imageName: "star.fill"))
]

for content in cardContents {
    content.bodyContent()
}
```

### 4. **Generic Repository Pattern**

In an app that needs to work with various models, such as `User`, `Product`, and `Order`, you might define a generic repository protocol:

```swift
protocol Repository {
    associatedtype Item
    func fetchAll() -> [Item]
}
```

However, because of the associated type, you can't use `Repository` directly in collections. Type erasure can help you work around this by hiding the associated type:

```swift
class AnyRepository<Item>: Repository {
    private let _fetchAll: () -> [Item]
    
    init<R: Repository>(_ repository: R) where R.Item == Item {
        _fetchAll = repository.fetchAll
    }
    
    func fetchAll() -> [Item] {
        _fetchAll()
    }
}
```

Now you can use different repositories (e.g., `UserRepository`, `ProductRepository`, `OrderRepository`) in the same collection:

```swift
let userRepo = AnyRepository(UserRepository())
let productRepo = AnyRepository(ProductRepository())
let orderRepo = AnyRepository(OrderRepository())

let repositories: [AnyRepository<Any>] = [userRepo, productRepo, orderRepo]

for repo in repositories {
    print(repo.fetchAll())
}
```

### 5. **UI Components with Dynamic Content**

Imagine you are building a dynamic form where the fields can be different types (e.g., `TextField`, `DatePicker`, `Picker`, etc.). You could define a protocol for these form fields and use type erasure to store them in a dynamic form builder:

```swift
protocol FormField {
    func render() -> AnyView
}

struct TextFieldField: FormField {
    let text: String
    
    func render() -> AnyView {
        AnyView(TextField(text: $text))
    }
}

struct DatePickerField: FormField {
    let date: Date
    
    func render() -> AnyView {
        AnyView(DatePicker("", selection: $date))
    }
}
```

You can then use a type-erased wrapper to store these fields in a single collection:

```swift
class AnyFormField: FormField {
    private let _render: () -> AnyView
    
    init<F: FormField>(_ field: F) {
        _render = field.render
    }
    
    func render() -> AnyView {
        _render()
    }
}
```

Now you can dynamically create and render a variety of form fields:

```swift
let fields: [AnyFormField] = [
    AnyFormField(TextFieldField(text: "Username")),
    AnyFormField(DatePickerField(date: Date()))
]

for field in fields {
    field.render()
}
```

### Conclusion

Type erasure allows you to abstract away concrete types and focus on behavior, making your Swift code more flexible and reusable in various scenarios. It's especially useful in situations involving protocols with associated types, handling dynamic content, or dealing with complex, generic systems like networking, UI components, or repositories.
