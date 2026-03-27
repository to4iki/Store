import Foundation

/// Protocol for key-value data persistence
///
/// Conform to this protocol to provide a custom storage backend
/// for ``PersistMiddleware``. The library ships with ``UserDefaultsStorage``
/// as a default implementation.
public protocol PersistStorage: Sendable {
  /// Load data for the given key
  ///
  /// - Parameter key: The storage key
  /// - Returns: The stored data, or `nil` if no data exists
  func load(key: String) -> Data?

  /// Save data for the given key
  ///
  /// - Parameters:
  ///   - key: The storage key
  ///   - data: The data to persist
  func save(key: String, data: Data)

  /// Remove data for the given key
  ///
  /// - Parameter key: The storage key
  func remove(key: String)
}

/// A ``PersistStorage`` implementation backed by `UserDefaults`
///
/// `UserDefaults` is thread-safe, so this type opts into `Sendable`
/// via `@unchecked Sendable`.
public final class UserDefaultsStorage: PersistStorage, @unchecked Sendable {
  private let defaults: UserDefaults

  /// Creates a storage backed by the given `UserDefaults` instance
  ///
  /// - Parameter defaults: The `UserDefaults` instance to use (defaults to `.standard`)
  public init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  public func load(key: String) -> Data? {
    defaults.data(forKey: key)
  }

  public func save(key: String, data: Data) {
    defaults.set(data, forKey: key)
  }

  public func remove(key: String) {
    defaults.removeObject(forKey: key)
  }
}
