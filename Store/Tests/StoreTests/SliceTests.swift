import Testing

@testable import Store

@Suite
struct SliceTests {
  struct FishSlice: Slice {
    struct State: Sendable {
      var fishes: Int = 0
    }

    struct Action {
      let addFish: () -> Void
    }

    func create(_ set: StateSet<State>) -> (state: State, action: Action) {
      let state = State()
      let action = Action(
        addFish: {
          set { $0.fishes += 1 }
        }
      )
      return (state, action)
    }
  }

  struct BearSlice: Slice {
    struct State: Sendable {
      var bears: Int = 0
    }

    struct Action {
      let addBear: () -> Void
    }

    func create(_ set: StateSet<State>) -> (state: State, action: Action) {
      let state = State()
      let action = Action(
        addBear: {
          set { $0.bears += 1 }
        }
      )
      return (state, action)
    }
  }

  struct CrossAction {
    let eatFish: () -> Void
  }

  @MainActor
  func useStore() -> (
    store: Store<CombinedState<FishSlice.State, BearSlice.State>>,
    action: CombinedAction<FishSlice.Action, BearSlice.Action, CrossAction>
  ) {
    createStoreWithSlices(FishSlice(), BearSlice()) { set in
      CrossAction(
        eatFish: {
          set { state in
            if state.fishes > 0 {
              state.fishes -= 1
              state.bears += 1
            }
          }
        }
      )
    }
  }

  @MainActor
  @Test
  func setState() {
    let (store, action) = useStore()
    #expect(store.state.fishes == 0)
    #expect(store.state.bears == 0)

    action.addFish()
    #expect(store.state.fishes == 1)
    #expect(store.state.bears == 0)

    action.addBear()
    #expect(store.state.fishes == 1)
    #expect(store.state.bears == 1)

    action.eatFish()
    #expect(store.state.fishes == 0)
    #expect(store.state.bears == 2)
  }
}
