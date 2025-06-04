import Store
import SwiftUI

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

struct BearFishFeature {
  typealias State = CombinedState<FishSlice.State, BearSlice.State>
  typealias Action = CombinedAction<FishSlice.Action, BearSlice.Action, CrossAction>

  struct CrossAction {
    let eatFish: () -> Void
  }

  @MainActor
  func useStore() -> (store: Store<State>, action: Action) {
    createStoreWithSlices(FishSlice(), BearSlice(), middleware: [SimplePrintMiddleware()]) { set in
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
        Text("🐟 Fishes: \(store.state.fishes)")
          .font(.title2)

        Button("Add Fish") {
          action.addFish()
        }
        .buttonStyle(.borderedProminent)
      }
      .padding()
      .background(Color.blue.opacity(0.1))
      .cornerRadius(12)

      // Bear Section
      VStack(spacing: 16) {
        Text("🐻 Bears: \(store.state.bears)")
          .font(.title2)

        HStack(spacing: 16) {
          Button("Add Bear") {
            action.addBear()
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
