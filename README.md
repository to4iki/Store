# Store
![Swift 6](https://img.shields.io/badge/swift-6-orange.svg)
![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue.svg)
![SPM compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)
![MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg)
![Coverage](https://raw.githubusercontent.com/to4iki/Store/main/docs/coverage.svg)

A small, fast and scalable state-management solution using simplified flux principles, inspired by [Zustand](https://github.com/pmndrs/zustand).

## Installation
### Swift Package Manager
```swift
.package(url: "https://github.com/to4iki/Store", from: <#version#>)
```

## Basic Example

Define your state and actions:

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
    let (store, action) = createStore(initialState: State()) { set in
      Action(
        increment: {
          set { $0.count += 1 }
        },
        decrement: {
          set { $0.count -= 1 }
        },
        reset: {
          store.resetState()
        }
      )
    }
    return (store, action)
  }
}
```

Use it in your SwiftUI view:

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

## Documentation

- [Slices](docs/slices.md) - Modularize state with the slices pattern
- [Middleware](docs/middleware.md) - Extend Store with logging and custom middleware
- [Reset / Replace State](docs/reset-replace.md) - Reset or replace the entire state

## License
Store is released under the MIT license.
