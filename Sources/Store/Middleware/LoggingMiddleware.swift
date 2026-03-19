/// Configurable logging middleware for intercepting state updates
///
/// Unlike ``SimplePrintMiddleware``, this middleware allows you to customize
/// the log output destination, state formatting, and which phases to log.
///
/// ```swift
/// let store = Store(
///   initialState: MyState(),
///   middleware: [LoggingMiddleware<MyState>()]
/// )
/// ```
///
/// You can provide a custom handler and state transform:
/// ```swift
/// LoggingMiddleware<MyState>(
///   handler: { os_log("%{public}@", $0) },
///   stateTransform: { "\($0.importantField)" }
/// )
/// ```
public struct LoggingMiddleware<State>: Middleware {
  private let handler: @Sendable (String) -> Void
  private let stateTransform: (@Sendable (State) -> String)?
  private let logBefore: Bool
  private let logAfter: Bool

  /// Creates a new logging middleware with the given configuration
  ///
  /// - Parameters:
  ///   - handler: A closure that handles log output. Defaults to `print`.
  ///   - stateTransform: An optional closure to customize state formatting.
  ///     When `nil`, uses `String(describing:)`.
  ///   - logBefore: Whether to log state before the update. Defaults to `true`.
  ///   - logAfter: Whether to log state after the update. Defaults to `true`.
  public init(
    handler: @escaping @Sendable (String) -> Void = { print($0) },
    stateTransform: (@Sendable (State) -> String)? = nil,
    logBefore: Bool = true,
    logAfter: Bool = true
  ) {
    self.handler = handler
    self.stateTransform = stateTransform
    self.logBefore = logBefore
    self.logAfter = logAfter
  }

  public func apply(currentState: State, next: StateSet<State>) -> StateSet<State> {
    return StateSet<State> { updater in
      if logBefore {
        handler("🔄 Before state update: \(formatState(currentState))")
      }

      var newState = currentState
      updater(&newState)

      if logAfter {
        handler("🔄 After state update: \(formatState(newState))")
      }

      next { state in
        state = newState
      }
    }
  }

  private func formatState(_ state: State) -> String {
    if let stateTransform {
      return stateTransform(state)
    }
    return String(describing: state)
  }
}
