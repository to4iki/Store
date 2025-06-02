# Store
![Swift 6](https://img.shields.io/badge/swift-6-orange.svg)
![SPM compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)
![MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg)

A small, fast and scalable state-management solution using simplified flux principles.

## Installation
### Swift Package Manager
```swift
.package(url: "https://github.com/to4iki/Store", from: <#version#>)
```

## Usage
Store provides a simple and intuitive API for state management, inspired by Zustand. It supports both iOS 17+ with `@Observable` and iOS 16 and below with `ObservableObject`.

### Basic Example
First, define your state and actions:

```swift
import Store

struct CounterFeature {
  struct State: Sendable {
    var count: Int = 0
  }

  struct Action {
    let increment: () -> Void
    let decrement: () -> Void
    let reset: () -> Void
  }

  @MainActor
  func useStore() -> (store: Store<State>, action: Action) {
    createStore(initialState: State()) { set in
      Action(
        increment: {
          set { $0.count += 1 }
        },
        decrement: {
          set { $0.count -= 1 }
        },
        reset: {
          set { $0.count = 0 }
        }
      )
    }
  }
}
```

Then use it in your SwiftUI view:

#### iOS 17+ (with @Observable)
```swift
import SwiftUI

struct CounterView: View {
  @State private var store: Store<CounterFeature.State>
  private let action: CounterFeature.Action

  init() {
    let feature = CounterFeature()
    let (store, action) = feature.useStore()
    self._store = State(initialValue: store)
    self.action = action
  }

  var body: some View {
    VStack(spacing: 20) {
      Text("Count: \(store.state.count)")
        .font(.title)

      HStack(spacing: 16) {
        Button("−") { action.decrement() }
        Button("Reset") { action.reset() }
        Button("+") { action.increment() }
      }
    }
  }
}
```

#### iOS 16 and below (with ObservableObject)
```swift
import SwiftUI

struct CounterView: View {
  @StateObject private var store: Store<CounterFeature.State>
  private let action: CounterFeature.Action

  init() {
    let feature = CounterFeature()
    let (store, action) = feature.useStore()
    self._store = StateObject(wrappedValue: store)
    self.action = action
  }

  var body: some View {
    VStack(spacing: 20) {
      Text("Count: \(store.state.count)")
        .font(.title)

      HStack(spacing: 16) {
        Button("−") { action.decrement() }
        Button("Reset") { action.reset() }
        Button("+") { action.increment() }
      }
    }
  }
}
```

## Middleware
Middleware provides a way to extend Store with additional functionality. Think of middleware as a pipeline that wraps around state updates - each middleware can inspect the current state, modify the update process, or perform side effects like logging.

### Using Middleware
Add middleware to your store by passing them to the `middlewares` parameter:

```swift
let (store, action) = createStore(
  initialState: CounterFeature.State(),
  middlewares: [SimplePrintMiddleware<CounterFeature.State>()]
) { set in
  // ... action definitions
}
```

## License
Store is released under the MIT license.
