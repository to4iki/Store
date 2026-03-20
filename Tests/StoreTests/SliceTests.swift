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

    func createAction(_ set: StateSet<State>) -> Action {
      Action(
        addFish: {
          set { $0.fishes += 1 }
        }
      )
    }
  }

  struct BearSlice: Slice {
    struct State: Sendable {
      var bears: Int = 0
    }

    struct Action {
      let addBear: () -> Void
    }

    func createAction(_ set: StateSet<State>) -> Action {
      Action(
        addBear: {
          set { $0.bears += 1 }
        }
      )
    }
  }

  // Combined state - user defines their own flat struct
  struct AppState: Sendable {
    var fish = FishSlice.State()
    var bear = BearSlice.State()
  }

  struct AppAction {
    let fish: FishSlice.Action
    let bear: BearSlice.Action
    let eatFish: () -> Void
  }

  @MainActor
  func useStore() -> (store: Store<AppState>, action: AppAction) {
    createStore(initialState: AppState()) { set, _ in
      AppAction(
        fish: FishSlice().createAction(set.scoped(\.fish)),
        bear: BearSlice().createAction(set.scoped(\.bear)),
        eatFish: {
          set { state in
            if state.fish.fishes > 0 {
              state.fish.fishes -= 1
              state.bear.bears += 1
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
    #expect(store.state.fish.fishes == 0)
    #expect(store.state.bear.bears == 0)

    action.fish.addFish()
    #expect(store.state.fish.fishes == 1)
    #expect(store.state.bear.bears == 0)

    action.bear.addBear()
    #expect(store.state.fish.fishes == 1)
    #expect(store.state.bear.bears == 1)

    action.eatFish()
    #expect(store.state.fish.fishes == 0)
    #expect(store.state.bear.bears == 2)
  }

  @MainActor @Test
  func scopedUpdateIsolation() {
    let (store, action) = useStore()
    action.fish.addFish()
    action.fish.addFish()
    #expect(store.state.fish.fishes == 2)
    #expect(store.state.bear.bears == 0)

    action.bear.addBear()
    #expect(store.state.fish.fishes == 2)
    #expect(store.state.bear.bears == 1)
  }

  @MainActor @Test
  func eatFishWhenNoFish() {
    let (store, action) = useStore()
    #expect(store.state.fish.fishes == 0)
    #expect(store.state.bear.bears == 0)

    action.eatFish()
    #expect(store.state.fish.fishes == 0)
    #expect(store.state.bear.bears == 0)
  }
}
