/// A closure type for updating state immutably
///
/// This function type uses an inout parameter to allow direct modification of state.
/// It enables safe and efficient state updates by working with mutable references
/// while maintaining immutability at the store level.
///
/// - Parameter state: The state to be modified (inout parameter)
public typealias StateUpdater<State> = (inout State) -> Void

/// A wrapper structure for state setting operations
///
/// StateSet wraps a StateUpdater function and provides a clean interface for
/// updating store state. It implements `callAsFunction` to make instances
/// callable like regular functions, providing an intuitive API for state updates.
public struct StateSet<State> {
  private let set: (StateUpdater<State>) -> Void

  init(_ set: @escaping (StateUpdater<State>) -> Void) {
    self.set = set
  }

  /// Makes the StateSet instance callable as a function
  ///
  /// This method enables the StateSet instance to be called directly like a function,
  /// providing a clean and intuitive API for state updates.
  ///
  /// - Parameter updater: A closure that modifies the state
  public func callAsFunction(_ updater: StateUpdater<State>) {
    set(updater)
  }

  /// Creates a scoped setter that operates on a child state
  ///
  /// This method enables slice composition by creating a StateSet that targets
  /// a specific portion of the parent state via a WritableKeyPath.
  ///
  /// - Parameter keyPath: A writable key path from the parent state to the child state
  /// - Returns: A new StateSet scoped to the child state
  public func scoped<ChildState>(_ keyPath: WritableKeyPath<State, ChildState>) -> StateSet<ChildState> {
    StateSet<ChildState> { childUpdater in
      self { state in
        childUpdater(&state[keyPath: keyPath])
      }
    }
  }
}
