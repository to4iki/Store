/// Middleware protocol for intercepting state updates
///
/// Middleware allows you to inject custom logic before and after state changes,
/// such as logging, validation, or persistence.
public protocol Middleware<State> {
  associatedtype State

  /// Apply middleware logic to the state update chain
  ///
  /// - Parameters:
  ///   - currentState: The current state before update
  ///   - next: The next middleware or final state setter in the chain
  /// - Returns: A new StateSet with the middleware logic applied
  func apply(currentState: State, next: StateSet<State>) -> StateSet<State>
}
