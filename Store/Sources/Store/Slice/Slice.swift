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

// MARK: - Combined State Types

/// Combined state for two slices with full flat access via @dynamicMemberLookup
@dynamicMemberLookup
public struct CombinedState<S1: Sendable, S2: Sendable>: Sendable {
  /// @available(*, deprecated, message: "Use keypath-based property access via @dynamicMemberLookup instead of direct slice access")
  public var slice1: S1
  /// @available(*, deprecated, message: "Use keypath-based property access via @dynamicMemberLookup instead of direct slice access")
  public var slice2: S2

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
  /// @available(*, deprecated, message: "Use keypath-based property access via @dynamicMemberLookup instead of direct slice access")
  public let slice1: A1
  /// @available(*, deprecated, message: "Use keypath-based property access via @dynamicMemberLookup instead of direct slice access")
  public let slice2: A2
  /// @available(*, deprecated, message: "Use keypath-based property access via @dynamicMemberLookup instead of direct slice access")
  public let crossSlice: CrossAction

  public init(slice1: A1, slice2: A2, crossSlice: CrossAction) {
    self.slice1 = slice1
    self.slice2 = slice2
    self.crossSlice = crossSlice
  }

  public subscript<T>(dynamicMember keyPath: KeyPath<A1, T>) -> T {
    slice1[keyPath: keyPath]
  }

  public subscript<T>(dynamicMember keyPath: KeyPath<A2, T>) -> T {
    slice2[keyPath: keyPath]
  }

  public subscript<T>(dynamicMember keyPath: KeyPath<CrossAction, T>) -> T {
    crossSlice[keyPath: keyPath]
  }
}
