/// A handle for a selector-based subscription that can be cancelled
///
/// When a subscription is created via `Store.subscribe(selector:listener:)`,
/// a `Subscription` instance is returned. Call `cancel()` to stop receiving
/// notifications when the selected value changes.
@MainActor
public final class Subscription {
  private var onCancel: (() -> Void)?

  init(onCancel: @escaping () -> Void) {
    self.onCancel = onCancel
  }

  /// Cancels the subscription, stopping further listener invocations
  public func cancel() {
    onCancel?()
    onCancel = nil
  }
}
