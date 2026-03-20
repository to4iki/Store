import Testing

@testable import Store

@Suite
struct GetStateTests {
  struct State: Sendable {
    var count: Int = 0
  }

  struct Action {
    let increment: () -> Void
    let getCount: () -> Int
  }

  @MainActor
  func useStore() -> (store: Store<State>, action: Action) {
    createStore(initialState: State()) { set, get in
      Action(
        increment: {
          set { $0.count += 1 }
        },
        getCount: {
          get().count
        }
      )
    }
  }

  @MainActor
  @Test
  func getState() {
    let (store, action) = useStore()
    #expect(action.getCount() == 0)
    action.increment()
    #expect(action.getCount() == 1)
    #expect(store.state.count == 1)
  }

  @MainActor
  @Test
  func getStateReflectsLatestState() {
    let (_, action) = useStore()
    action.increment()
    action.increment()
    action.increment()
    #expect(action.getCount() == 3)
  }
}
