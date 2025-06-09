import Testing

@testable import Store

@Suite
struct StoreTests {
  struct State: Sendable {
    var count: Int = 0
  }

  struct Action {
    let increment: () -> Void
    let decrement: () -> Void
  }

  @MainActor
  func useStore() -> (store: Store<State>, action: Action) {
    createStore(initialState: State()) { set in
      Action(
        increment: {
          set { $0.count += 1 }
        },
        decrement: {
          set { $0.count -= 1 }
        }
      )
    }
  }

  @MainActor
  @Test
  func setState() {
    let (store, action) = useStore()
    #expect(store.state.count == 0)
    action.increment()
    #expect(store.state.count == 1)
    action.decrement()
    #expect(store.state.count == 0)
  }
}
