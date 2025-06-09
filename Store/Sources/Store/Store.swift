import Observation

/// A Zustand-like state management store for SwiftUI
///
/// This store provides reactive state management using SwiftUI's Observable mechanisms.
/// State changes are always executed on the MainActor, ensuring automatic UI updates.
/// The store follows the Zustand pattern of immutable state updates through functional setters.
///
/// - SeeAlso: https://github.com/pmndrs/zustand
@Observable
@MainActor
public final class Store<State: Sendable> {
  /// The current state of the store
  ///
  /// This property is read-only from external access. To modify the state,
  /// use the `set(_:)` method which ensures proper change notifications.
  ///
  /// - Note: State changes automatically trigger SwiftUI view updates via @Observable
  public private(set) var state: State

  /// Initializes the store with an initial state
  ///
  /// - Parameter initialState: The initial state value for the store
  init(initialState: State) {
    self.state = initialState
  }

  /// Updates the store's state using a functional setter
  ///
  /// This method creates a copy of the current state, applies the updater function
  /// to modify it, and then sets the new state.
  ///
  /// - Parameter updater: A closure that receives an inout reference to the state for modification
  func set(_ updater: StateUpdater<State>) {
    var newState = state
    updater(&newState)
    self.state = newState
  }
}

/// Creates a store and its associated actions
///
/// This factory function takes an initial state, optional middleware, and an action creation function,
/// then returns a store instance with its corresponding actions. The actions
/// provide an interface for updating the state in a type-safe manner.
///
/// The pattern follows Zustand's approach where actions are created by passing
/// a setter function that can be called to update the store's state.
///
/// - Parameters:
///   - initialState: The initial state for the store
///   - middlewares: Array of middleware to apply to state updates (applied in reverse order)
///   - createAction: A function that receives a StateSet and returns actions
/// - Returns: A tuple containing the created store and its actions
///
/// ## Usage Example
/// ```swift
/// struct AppState {
///   var count: Int = 0
/// }
///
/// struct AppActions {
///   let increment: () -> Void
///   let decrement: () -> Void
/// }
///
/// let (store, actions) = createStore(initialState: AppState()) { set in
///   AppActions(
///     increment: { set { $0.count += 1 } },
///     decrement: { set { $0.count -= 1 } }
///   )
/// }
/// ```
@MainActor
public func createStore<State, Action>(
  initialState: State,
  middleware: [any Middleware<State>] = [],
  createAction: (StateSet<State>) -> Action
) -> (store: Store<State>, action: Action) {
  let store = Store(initialState: initialState)

  let baseSetter = StateSet<State> { updater in
    store.set(updater)
  }

  let setter = middleware.reversed().reduce(baseSetter) { nextSetter, middleware in
    StateSet<State> { updater in
      let middlewareApply = middleware.apply(currentState: store.state, next: nextSetter)
      middlewareApply(updater)
    }
  }

  let action = createAction(setter)
  return (store, action)
}
