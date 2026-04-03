# Middleware

Middleware provides a way to extend Store with additional functionality. Think of middleware as a pipeline that wraps around state updates - each middleware can inspect the current state, modify the update process, or perform side effects like logging.

## LoggingMiddleware

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

## Custom Middleware

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
