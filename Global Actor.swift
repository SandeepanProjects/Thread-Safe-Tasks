//
//  Global Actor.swift
//  
//
//  Created by Apple on 09/03/25.
//

import Foundation

### **What is a Global Actor in Swift?**

In Swift 5.5 and later, **global actors** are a new concurrency feature that allows you to ensure that certain pieces of code (typically related to UI or shared resources) run on a specific thread or queue. They provide a way to enforce thread-safety for data and methods by restricting the access to certain parts of the program to a specific actor, which executes asynchronously.

A **global actor** is a type of actor that provides a shared, globally accessible execution context for certain operations. A global actor can be used to ensure that specific tasks or operations are always performed on a designated thread or queue, which is typically the **main thread** in the case of UI updates or background threads for tasks that should not block the UI.

### **Global Actors in Swift:**

- **`@MainActor`**: The most commonly used global actor, which ensures that code runs on the main thread (used for UI updates).
- **Custom Global Actors**: You can define your own global actors if you need to ensure a particular set of tasks are always performed on a specific queue.

### **When to Use Global Actors:**

1. **UI Updates (Main Thread)**:
   - If you are working with UI components (such as updating `UILabel`, `UIButton`, or other UI elements), you must ensure that these updates happen on the **main thread**. `@MainActor` is used to ensure that the code runs on the main thread, thus preventing race conditions or crashes that may occur when UI updates are attempted from a background thread.
   
   **Example:**

   ```swift
   @MainActor
   func updateUI() {
       // Code to update UI components (e.g., labels, buttons, etc.)
       self.label.text = "Updated Text"
   }
   ```

   In this case, `@MainActor` ensures that `updateUI()` runs on the main thread.

2. **Managing Shared Resources**:
   - If you have shared resources or data that need to be accessed by multiple tasks or threads (for example, managing a database or a network connection), you can use custom global actors to ensure that these resources are accessed in a thread-safe way.

   **Example:**
   
   ```swift
   @globalActor
   struct MySharedResourceActor {
       static var shared: MySharedResourceActor { MySharedResourceActor() }
   }

   @MySharedResourceActor
   func accessSharedResource() {
       // Access or modify shared resource here, ensuring thread safety.
   }
   ```

3. **Concurrency Control**:
   - If your app uses background processing or tasks that must be executed in a specific order, you can use global actors to control the execution context. For example, you might want certain tasks to run on a specific queue, or you might need to ensure that operations on certain shared resources are serialized.

4. **Ensuring Thread Safety**:
   - Global actors are particularly useful for ensuring that access to a shared resource happens serially on a specific queue or thread. This is especially important when dealing with tasks that involve mutable shared state. Using an actor to encapsulate the state prevents race conditions.

### **Example of Using `@MainActor`:**

When working with UI updates, it’s critical that you ensure the code runs on the main thread. By marking functions with `@MainActor`, you ensure that the tasks are dispatched to the main thread automatically.

```swift
class ViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    
    @MainActor
    func updateLabel(with text: String) {
        label.text = text
    }

    func performBackgroundTask() {
        Task {
            // Simulate background task
            await Task.sleep(2 * 1_000_000_000)  // sleep for 2 seconds

            // Now update the UI on the main thread
            await updateLabel(with: "Task completed!")
        }
    }
}
```

In this example:
- `updateLabel(with:)` is marked with `@MainActor`, meaning that no matter where it is called from (e.g., background task or some other concurrent code), it will always execute on the main thread to safely update the UI.
- `performBackgroundTask()` runs some background work and, when done, calls `updateLabel(with:)` to safely update the UI on the main thread.

### **Example of Using a Custom Global Actor:**

In certain cases, you may want to use a custom global actor to ensure that certain tasks are run on a specific queue or thread. Here's an example of defining and using a custom global actor:

```swift
@globalActor
struct BackgroundActor {
    static let shared = DispatchQueue(label: "com.example.backgroundQueue")
}

@BackgroundActor
func performBackgroundWork() {
    // This function will run on the custom global actor's queue (backgroundQueue)
    print("This is running on the background queue.")
}
```

In this example:
- `BackgroundActor` is a custom global actor associated with a specific queue (`backgroundQueue`).
- Any code annotated with `@BackgroundActor` will run on `backgroundQueue`, ensuring the execution context is controlled.

### **Summary of Global Actors and Their Use Cases:**

- **`@MainActor`**: Ensures that the code runs on the **main thread**, which is crucial for updating the UI or performing tasks that must happen on the main thread.
- **Custom Global Actors**: Allow you to define your own global actors for controlling execution contexts for specific queues or threads (e.g., for background processing or serializing access to shared resources).
- **When to Use**:
  - UI updates: Ensure they happen on the main thread.
  - Shared resource access: Use global actors to serialize access to resources.
  - Task serialization: Control when and where tasks execute, such as limiting access to specific queues or threads.

By using global actors, you can safely manage concurrency, avoid race conditions, and ensure that tasks run on the appropriate thread or queue in a structured and predictable way.
