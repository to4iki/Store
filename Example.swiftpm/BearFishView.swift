import Store
import SwiftUI

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

struct BearFishFeature {
  struct State: Sendable {
    var fish = FishSlice.State()
    var bear = BearSlice.State()
  }

  struct Action {
    let fish: FishSlice.Action
    let bear: BearSlice.Action
    let eatFish: () -> Void
  }

  @MainActor
  func useStore() -> (store: Store<State>, action: Action) {
    createStore(initialState: State(), middleware: [SimplePrintMiddleware()]) { set in
      Action(
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
}

struct BearFishView: View {
  @State private var store: Store<BearFishFeature.State>
  private let action: BearFishFeature.Action

  init() {
    let feature = BearFishFeature()
    let (store, action) = feature.useStore()
    self._store = State(initialValue: store)
    self.action = action
  }

  var body: some View {
    VStack(spacing: 40) {
      Text("🐻 Bear & Fish Store 🐟")
        .font(.largeTitle)

      // Fish Section
      VStack(spacing: 16) {
        Text("🐟 Fishes: \(store.state.fish.fishes)")
          .font(.title2)

        Button("Add Fish") {
          action.fish.addFish()
        }
        .buttonStyle(.borderedProminent)
      }
      .padding()
      .background(Color.blue.opacity(0.1))
      .cornerRadius(12)

      // Bear Section
      VStack(spacing: 16) {
        Text("🐻 Bears: \(store.state.bear.bears)")
          .font(.title2)

        HStack(spacing: 16) {
          Button("Add Bear") {
            action.bear.addBear()
          }
          .buttonStyle(.borderedProminent)

          Button("Bear Eats Fish") {
            action.eatFish()
          }
          .buttonStyle(.bordered)
        }
      }
      .padding()
      .background(Color.brown.opacity(0.1))
      .cornerRadius(12)

      Spacer()
    }
    .padding()
    .navigationTitle("Bear & Fish")
  }
}

#Preview {
  BearFishView()
}
