import Testing

@testable import Store

@Suite
struct SubscriptionTests {
  struct State: Sendable {
    var count: Int = 0
  }

  struct Action {
    let increment: () -> Void
  }

  @MainActor
  func useStore() -> (store: Store<State>, action: Action) {
    createStore(initialState: State()) { set in
      Action(
        increment: { set { $0.count += 1 } }
      )
    }
  }

  @MainActor
  @Test
  func subscribeReceivesStateChanges() {
    let (store, action) = useStore()

    var received: [(newState: State, previousState: State)] = []
    _ = store.subscribe { newState, previousState in
      received.append((newState, previousState))
    }

    action.increment()

    #expect(received.count == 1)
    #expect(received[0].newState.count == 1)
    #expect(received[0].previousState.count == 0)
  }

  @MainActor
  @Test
  func subscriptionCancel() {
    let (store, action) = useStore()

    var callCount = 0
    let subscription = store.subscribe { _, _ in
      callCount += 1
    }

    action.increment()
    #expect(callCount == 1)

    subscription.cancel()

    action.increment()
    #expect(callCount == 1)
  }

  @MainActor
  @Test
  func multipleSubscriptions() {
    let (store, action) = useStore()

    var callCountA = 0
    var callCountB = 0
    _ = store.subscribe { _, _ in callCountA += 1 }
    _ = store.subscribe { _, _ in callCountB += 1 }

    action.increment()

    #expect(callCountA == 1)
    #expect(callCountB == 1)
  }

  @MainActor
  @Test
  func destroyClearsAllSubscriptions() {
    let (store, action) = useStore()

    var callCount = 0
    _ = store.subscribe { _, _ in callCount += 1 }
    _ = store.subscribe { _, _ in callCount += 1 }

    action.increment()
    #expect(callCount == 2)

    store.destroy()

    action.increment()
    #expect(callCount == 2)
  }
}
