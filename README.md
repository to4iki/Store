# Store
![Swift 6](https://img.shields.io/badge/swift-6-orange.svg)
![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue.svg)
![SPM compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)
![MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg)

A small, fast and scalable state-management solution using simplified flux principles, inspired by [Zustand](https://github.com/pmndrs/zustand).

## Installation
### Swift Package Manager
```swift
.package(url: "https://github.com/to4iki/Store", from: <#version#>)
```

## Usage
Store provides a simple and intuitive API for state management, inspired by Zustand.

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

## Middleware
Middleware provides a way to extend Store with additional functionality. Think of middleware as a pipeline that wraps around state updates - each middleware can inspect the current state, modify the update process, or perform side effects like logging.

### LoggingMiddleware
A configurable logging middleware that supports custom log handlers, state formatting, and selective phase logging:

```swift
// Basic usage (prints before/after state)
let (store, action) = createStore(
  initialState: CounterFeature.State(),
  middleware: [LoggingMiddleware<CounterFeature.State>()]
) { set in
  // ... action definitions
}

// Advanced: custom handler, selective field logging, after-only
let (store, action) = createStore(
  initialState: CounterFeature.State(),
  middleware: [
    LoggingMiddleware<CounterFeature.State>(
      handler: { os_log("%{public}@", $0) },
      stateTransform: { "count=\($0.count)" },
      logBefore: false,
      logAfter: true
    )
  ]
) { set in
  // ... action definitions
}
```

### Custom Middleware
Implement the `Middleware` protocol to create your own:

```swift
struct ValidationMiddleware: Middleware {
  func apply(currentState: AppState, next: StateSet<AppState>) -> StateSet<AppState> {
    StateSet<AppState> { updater in
      var newState = currentState
      updater(&newState)
      // Add custom logic (validation, transformation, etc.)
      next { state in state = newState }
    }
  }
}
```

## Slices
Slices allow you to modularize your state management by breaking down large stores into smaller, focused units that can be composed together. Like [Zustand's slices pattern](https://zustand.docs.pmnd.rs/learn/guides/slices-pattern), each slice defines its own state and actions, and you compose them into a single store using `createStore` with `StateSet.scoped`.

### Defining Slices
Implement the `Slice` protocol to define each slice:

```swift
import Store

struct FishSlice: Slice {
  struct State: Sendable {
    var fishes: Int = 0
  }

  struct Action {
    let addFish: () -> Void
  }

  func createAction(_ set: StateSet<State>) -> Action {
    Action(
      addFish: {
        set { $0.fishes += 1 }
      }
    )
  }
}

struct BearSlice: Slice {
  struct State: Sendable {
    var bears: Int = 0
  }

  struct Action {
    let addBear: () -> Void
  }

  func createAction(_ set: StateSet<State>) -> Action {
    Action(
      addBear: {
        set { $0.bears += 1 }
      }
    )
  }
}
```

### Composing Slices
Compose slices into a single store using `createStore` and `set.scoped`. Define your own combined state and action types — no wrapper types needed:

```swift
struct BearFishFeature {
  struct State: Sendable {
    var fish = FishSlice.State()
    var bear = BearSlice.State()
  }

  struct Action {
    let fish: FishSlice.Action
    let bear: BearSlice.Action
    let eatFish: () -> Void
  }

  @MainActor
  func useStore() -> (store: Store<State>, action: Action) {
    createStore(initialState: State()) { set in
      Action(
        fish: FishSlice().createAction(set.scoped(\.fish)),
        bear: BearSlice().createAction(set.scoped(\.bear)),
        eatFish: {
          set { state in
            if state.fish.fishes > 0 {
              state.fish.fishes -= 1
              state.bear.bears += 1
            }
          }
        }
      )
    }
  }
}
```

Then use it in your SwiftUI view:

```swift
struct BearFishView: View {
  @State private var store: Store<BearFishFeature.State>
  private let action: BearFishFeature.Action

  init() {
    let feature = BearFishFeature()
    let (store, action) = feature.useStore()
    self._store = State(initialValue: store)
    self.action = action
  }

  var body: some View {
    VStack {
      Text("🐟 Fishes: \(store.state.fish.fishes)")
      Text("🐻 Bears: \(store.state.bear.bears)")

      HStack {
        Button("Add Fish") { action.fish.addFish() }
        Button("Add Bear") { action.bear.addBear() }
        Button("Bear Eats Fish") { action.eatFish() }
      }
    }
  }
}
```

## License
Store is released under the MIT license.
