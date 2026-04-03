# Reset / Replace State

Store supports resetting to the initial state and replacing the entire state at once.

## resetState

`Store.resetState()` restores the store to the state provided at creation time:

```swift
let (store, action) = createStore(initialState: State()) { set in
  Action(
    reset: {
      store.resetState()  // Restores to the initial state
    }
  )
}
```

## StateSet.replace

`StateSet.replace(_:)` replaces the entire state with a new value, unlike partial updates via `set { $0.field = value }`:

```swift
let (store, action) = createStore(initialState: State()) { set in
  Action(
    setTo100: {
      set.replace(State(count: 100))  // Replaces entire state
    }
  )
}
```
