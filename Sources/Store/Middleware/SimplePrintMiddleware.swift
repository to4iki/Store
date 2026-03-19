/// Middleware that prints before and after status updates
///
/// If you want to output the differences clearly,
/// use https://github.com/pointfreeco/swift-custom-dump
@available(*, deprecated, message: "Use LoggingMiddleware instead")
public struct SimplePrintMiddleware<State>: Middleware {
  public init() {}

  public func apply(currentState: State, next: StateSet<State>) -> StateSet<State> {
    return StateSet<State> { updater in
      print("🔄 Before state update: \(currentState)")

      var newState = currentState
      updater(&newState)
      print("🔄 After state update: \(newState)")

      next { state in
        state = newState
      }
    }
  }
}
