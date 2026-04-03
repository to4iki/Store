# Slices

Slices allow you to modularize your state management by breaking down large stores into smaller, focused units that can be composed together. Like [Zustand's slices pattern](https://zustand.docs.pmnd.rs/learn/guides/slices-pattern), each slice defines its own state and actions, and you compose them into a single store using `createStore` with `StateSet.scoped`.

## Defining Slices

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

## Composing Slices

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

## Using in SwiftUI

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
