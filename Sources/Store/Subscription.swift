/// A handle for managing a store subscription
///
/// When you subscribe to a store, a `Subscription` is returned that can be used
/// to cancel the subscription when it is no longer needed.
@MainActor
public final class Subscription: Sendable {
  private let onCancel: @MainActor @Sendable () -> Void

  init(onCancel: @escaping @MainActor @Sendable () -> Void) {
    self.onCancel = onCancel
  }

  /// Cancels this subscription
  ///
  /// After calling this method, the listener will no longer receive state change notifications.
  public func cancel() {
    onCancel()
  }
}
