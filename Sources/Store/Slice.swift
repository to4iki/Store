/// A protocol defining a state slice with its associated state and action
///
/// Slices allow you to modularize your state management by breaking down
/// large stores into smaller, focused units that can be composed together.
/// Each slice defines its own state structure and the action that operate on it.
public protocol Slice {
  associatedtype State: Sendable
  associatedtype Action

  /// Creates the initial state and action for this slice
  ///
  /// - Parameter set: A state setter function that can update this slice's state
  /// - Returns: A tuple containing the initial state and action for this slice
  func create(_ set: StateSet<State>) -> (state: State, action: Action)
}

/// Creates a store with cross-slice action support for two slices
///
/// This function combines two slices into a single store, allowing for both
/// individual slice actions and cross-slice actions that can operate on the
/// combined state. Each slice maintains its own state and actions while
/// providing a unified interface through the combined state and actions.
///
/// - Parameters:
///   - slice1: The first slice to combine
///   - slice2: The second slice to combine
///   - middleware: Optional middleware array for the combined store
///   - action: A closure that creates cross-slice actions with access to the combined state setter
/// - Returns: A tuple containing the combined store and combined actions
@MainActor
public func createStoreWithSlices<Slice1: Slice, Slice2: Slice, CrossAction>(
  _ slice1: Slice1,
  _ slice2: Slice2,
  middleware: [any Middleware<CombinedState<Slice1.State, Slice2.State>>] = [],
  action: @escaping (StateSet<CombinedState<Slice1.State, Slice2.State>>) -> CrossAction
) -> (
  store: Store<CombinedState<Slice1.State, Slice2.State>>,
  action: CombinedAction<Slice1.Action, Slice2.Action, CrossAction>
) {
  let slice1Initial = slice1.create(StateSet<Slice1.State> { _ in })
  let slice2Initial = slice2.create(StateSet<Slice2.State> { _ in })
  let initialState = CombinedState(slice1: slice1Initial.state, slice2: slice2Initial.state)

  let (store, combinedAction) = createStore(
    initialState: initialState,
    middleware: middleware
  ) { set in
    let slice1Set = StateSet<Slice1.State> { updater in
      set { combinedState in
        updater(&combinedState.slice1)
      }
    }

    let slice2Set = StateSet<Slice2.State> { updater in
      set { combinedState in
        updater(&combinedState.slice2)
      }
    }

    let slice1Action = slice1.create(slice1Set).action
    let slice2Action = slice2.create(slice2Set).action
    let crossAction = action(set)

    return CombinedAction(slice1: slice1Action, slice2: slice2Action, action: crossAction)
  }

  return (store, combinedAction)
}

// MARK: - Combined State Types

/// Combined state for two slices with full flat access via @dynamicMemberLookup
@dynamicMemberLookup
public struct CombinedState<S1: Sendable, S2: Sendable>: Sendable {
  var slice1: S1
  var slice2: S2

  public init(slice1: S1, slice2: S2) {
    self.slice1 = slice1
    self.slice2 = slice2
  }

  public subscript<T>(dynamicMember keyPath: KeyPath<S1, T>) -> T {
    slice1[keyPath: keyPath]
  }

  public subscript<T>(dynamicMember keyPath: WritableKeyPath<S1, T>) -> T {
    get { slice1[keyPath: keyPath] }
    set { slice1[keyPath: keyPath] = newValue }
  }

  public subscript<T>(dynamicMember keyPath: KeyPath<S2, T>) -> T {
    slice2[keyPath: keyPath]
  }

  public subscript<T>(dynamicMember keyPath: WritableKeyPath<S2, T>) -> T {
    get { slice2[keyPath: keyPath] }
    set { slice2[keyPath: keyPath] = newValue }
  }
}

// MARK: - Combined Action Types

/// Combined action with cross-slice functionality for two slices
@dynamicMemberLookup
public struct CombinedAction<A1, A2, CrossAction> {
  let slice1: A1
  let slice2: A2
  let action: CrossAction

  public init(slice1: A1, slice2: A2, action: CrossAction) {
    self.slice1 = slice1
    self.slice2 = slice2
    self.action = action
  }

  public subscript<T>(dynamicMember keyPath: KeyPath<A1, T>) -> T {
    slice1[keyPath: keyPath]
  }

  public subscript<T>(dynamicMember keyPath: KeyPath<A2, T>) -> T {
    slice2[keyPath: keyPath]
  }

  public subscript<T>(dynamicMember keyPath: KeyPath<CrossAction, T>) -> T {
    action[keyPath: keyPath]
  }
}
