/// A protocol defining a state slice with its associated state and action
///
/// Slices allow you to modularize your state management by breaking down
/// large stores into smaller, focused units that can be composed together.
/// Each slice defines its own state type and the actions that operate on it.
/// The initial state is provided by the caller via `createStore(initialState:)`.
///
/// Compose slices using `createStore` with `StateSet.scoped`:
/// ```swift
/// createStore(initialState: AppState()) { set, _ in
///   AppAction(
///     fish: FishSlice().createAction(set.scoped(\.fish)),
///     bear: BearSlice().createAction(set.scoped(\.bear))
///   )
/// }
/// ```
public protocol Slice {
  associatedtype State: Sendable
  associatedtype Action

  /// Creates the actions for this slice
  ///
  /// - Parameter set: A state setter function scoped to this slice's state
  /// - Returns: The actions for this slice
  func createAction(_ set: StateSet<State>) -> Action
}
