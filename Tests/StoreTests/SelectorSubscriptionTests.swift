import Testing

@testable import Store

@Suite
struct SelectorSubscriptionTests {
  struct State: Sendable {
    var count: Int = 0
    var name: String = "initial"
  }

  struct Action {
    let increment: () -> Void
    let setName: (String) -> Void
  }

  @MainActor
  func useStore() -> (store: Store<State>, action: Action) {
    createStore(initialState: State()) { set in
      Action(
        increment: {
          set { $0.count += 1 }
        },
        setName: { name in
          set { $0.name = name }
        }
      )
    }
  }

  @MainActor
  @Test
  func subscribeWithEquatableSelector_firesOnChange() {
    let (store, action) = useStore()

    var receivedValues: [(old: Int, new: Int)] = []
    let subscription = store.subscribe(selector: { $0.count }) { oldValue, newValue in
      receivedValues.append((old: oldValue, new: newValue))
    }

    action.increment()
    #expect(receivedValues.count == 1)
    #expect(receivedValues[0].old == 0)
    #expect(receivedValues[0].new == 1)

    action.increment()
    #expect(receivedValues.count == 2)
    #expect(receivedValues[1].old == 1)
    #expect(receivedValues[1].new == 2)

    subscription.cancel()
  }

  @MainActor
  @Test
  func subscribeWithEquatableSelector_doesNotFireWhenUnchanged() {
    let (store, action) = useStore()

    var fireCount = 0
    let subscription = store.subscribe(selector: { $0.count }) { _, _ in
      fireCount += 1
    }

    // Changing name should not fire the count selector listener
    action.setName("updated")
    #expect(fireCount == 0)

    // Changing count should fire
    action.increment()
    #expect(fireCount == 1)

    subscription.cancel()
  }

  @MainActor
  @Test
  func subscribeWithCustomEqualityFn() {
    let (store, action) = useStore()

    var receivedValues: [(old: Int, new: Int)] = []
    // Custom equality: treat values as equal if both are even or both are odd
    let subscription = store.subscribe(
      selector: { $0.count },
      equalityFn: { $0 % 2 == $1 % 2 }
    ) { oldValue, newValue in
      receivedValues.append((old: oldValue, new: newValue))
    }

    // 0 -> 1: different parity, should fire
    action.increment()
    #expect(receivedValues.count == 1)

    // 1 -> 2: different parity, should fire
    action.increment()
    #expect(receivedValues.count == 2)

    subscription.cancel()
  }

  @MainActor
  @Test
  func subscriptionCancel_stopsNotifications() {
    let (store, action) = useStore()

    var fireCount = 0
    let subscription = store.subscribe(selector: { $0.count }) { _, _ in
      fireCount += 1
    }

    action.increment()
    #expect(fireCount == 1)

    subscription.cancel()

    action.increment()
    #expect(fireCount == 1)
  }

  @MainActor
  @Test
  func multipleSubscriptions_workIndependently() {
    let (store, action) = useStore()

    var countFires = 0
    var nameFires = 0

    let sub1 = store.subscribe(selector: { $0.count }) { _, _ in
      countFires += 1
    }
    let sub2 = store.subscribe(selector: { $0.name }) { _, _ in
      nameFires += 1
    }

    action.increment()
    #expect(countFires == 1)
    #expect(nameFires == 0)

    action.setName("hello")
    #expect(countFires == 1)
    #expect(nameFires == 1)

    sub1.cancel()
    sub2.cancel()
  }
}
