import Testing

@testable import Store

@Suite
struct ResetStateTests {
  struct State: Sendable {
    var count: Int = 0
    var name: String = "initial"
  }

  struct Action {
    let increment: () -> Void
    let setName: (String) -> Void
    let reset: () -> Void
  }

  @MainActor
  func useStore() -> (store: Store<State>, action: Action) {
    createStore(initialState: State()) { set in
      Action(
        increment: { set { $0.count += 1 } },
        setName: { name in set { $0.name = name } },
        reset: { set.replace(State()) }
      )
    }
  }

  @MainActor
  @Test
  func replaceState() {
    let (store, action) = useStore()

    action.increment()
    action.increment()
    action.setName("modified")
    #expect(store.state.count == 2)
    #expect(store.state.name == "modified")

    // Replace with a completely new state
    action.reset()
    #expect(store.state.count == 0)
    #expect(store.state.name == "initial")
  }

  @MainActor
  @Test
  func replaceWithCustomState() {
    let (store, _) = useStore()
    let setter = StateSet<State> { updater in store.set(updater) }

    // Replace with a custom state
    setter.replace(State(count: 42, name: "custom"))
    #expect(store.state.count == 42)
    #expect(store.state.name == "custom")
  }

  @MainActor
  @Test
  func resetState() {
    let (store, action) = useStore()

    action.increment()
    action.increment()
    action.setName("modified")
    #expect(store.state.count == 2)
    #expect(store.state.name == "modified")

    // Reset to initial state
    store.resetState()
    #expect(store.state.count == 0)
    #expect(store.state.name == "initial")
  }

  @MainActor
  @Test
  func resetStateThenMutateAgain() {
    let (store, action) = useStore()

    action.increment()
    store.resetState()
    #expect(store.state.count == 0)

    // Can still mutate after reset
    action.increment()
    #expect(store.state.count == 1)
  }
}
