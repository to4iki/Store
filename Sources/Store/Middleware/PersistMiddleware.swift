import Foundation

/// Middleware that automatically persists state changes to storage
///
/// After each state update, ``PersistMiddleware`` encodes the new state as JSON
/// and saves it to the provided ``PersistStorage``. Use ``loadState(key:storage:fallback:)``
/// to restore persisted state at initialization time.
///
/// ## Usage Example
/// ```swift
/// let storage = UserDefaultsStorage()
/// let initialState = PersistMiddleware<AppState>.loadState(
///   key: "app",
///   storage: storage,
///   fallback: AppState()
/// )
/// let (store, actions) = createStore(
///   initialState: initialState,
///   middleware: [PersistMiddleware<AppState>(key: "app", storage: storage)]
/// ) { set in
///   AppActions(...)
/// }
/// ```
public struct PersistMiddleware<State: Codable & Sendable>: Middleware {
  private let key: String
  private let storage: any PersistStorage

  /// Creates a persist middleware
  ///
  /// - Parameters:
  ///   - key: The storage key used to persist and restore state
  ///   - storage: The storage backend (defaults to ``UserDefaultsStorage``)
  public init(key: String, storage: any PersistStorage = UserDefaultsStorage()) {
    self.key = key
    self.storage = storage
  }

  public func apply(currentState: State, next: StateSet<State>) -> StateSet<State> {
    let key = self.key
    let storage = self.storage

    return StateSet<State> { updater in
      var newState = currentState
      updater(&newState)

      if let data = try? JSONEncoder().encode(newState) {
        storage.save(key: key, data: data)
      }

      next { state in
        state = newState
      }
    }
  }

  /// Restore persisted state from storage
  ///
  /// Use this method to hydrate the initial state when creating a store.
  /// If no data is found or decoding fails, the fallback value is returned.
  ///
  /// - Parameters:
  ///   - key: The storage key to load from
  ///   - storage: The storage backend
  ///   - fallback: The default state to use when no persisted data is available
  /// - Returns: The restored state, or the fallback if restoration fails
  public static func loadState(
    key: String,
    storage: any PersistStorage,
    fallback: State
  ) -> State {
    guard let data = storage.load(key: key) else {
      return fallback
    }
    return (try? JSONDecoder().decode(State.self, from: data)) ?? fallback
  }
}
