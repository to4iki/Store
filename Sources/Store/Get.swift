/// A wrapper structure for state reading operations
///
/// StateGet wraps a getter function and provides a clean interface for
/// reading the current store state. It implements `callAsFunction` to make instances
/// callable like regular functions, providing an intuitive API for state access.
public struct StateGet<State> {
  private let get: () -> State

  init(_ get: @escaping () -> State) {
    self.get = get
  }

  /// Makes the StateGet instance callable as a function
  ///
  /// This method enables the StateGet instance to be called directly like a function,
  /// providing a clean and intuitive API for reading the current state.
  ///
  /// - Returns: The current state
  public func callAsFunction() -> State {
    get()
  }

  /// Creates a scoped getter that reads a child state
  ///
  /// This method enables slice composition by creating a StateGet that targets
  /// a specific portion of the parent state via a KeyPath.
  ///
  /// - Parameter keyPath: A key path from the parent state to the child state
  /// - Returns: A new StateGet scoped to the child state
  public func scoped<ChildState>(_ keyPath: KeyPath<State, ChildState>) -> StateGet<ChildState> {
    StateGet<ChildState> {
      self()[keyPath: keyPath]
    }
  }
}
