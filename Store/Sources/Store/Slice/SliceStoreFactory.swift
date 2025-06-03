#if canImport(Observation)
  /// Creates a store with cross-slice action support for two slices
  @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
  @MainActor
  public func createStoreWithSlices<Slice1: Slice, Slice2: Slice, CrossAction>(
    _ slice1: Slice1,
    _ slice2: Slice2,
    middleware: [any Middleware<CombinedState<Slice1.State, Slice2.State>>] = [],
    crossSliceAction: @escaping (StateSet<CombinedState<Slice1.State, Slice2.State>>) -> CrossAction
  ) -> (
    store: Store<CombinedState<Slice1.State, Slice2.State>>,
    action: CombinedAction<Slice1.Action, Slice2.Action, CrossAction>
  ) {
    let slice1Initial = slice1.create(StateSet<Slice1.State> { _ in })
    let slice2Initial = slice2.create(StateSet<Slice2.State> { _ in })
    let initialState = CombinedState(slice1: slice1Initial.state, slice2: slice2Initial.state)

    let (store, combinedAction) = createStore(
      initialState: initialState,
      middleware: middleware
    ) { set in
      let slice1Set = StateSet<Slice1.State> { updater in
        set { combinedState in
          updater(&combinedState.slice1)
        }
      }

      let slice2Set = StateSet<Slice2.State> { updater in
        set { combinedState in
          updater(&combinedState.slice2)
        }
      }

      let slice1Action = slice1.create(slice1Set).action
      let slice2Action = slice2.create(slice2Set).action
      let crossAction = crossSliceAction(set)

      return CombinedAction(slice1: slice1Action, slice2: slice2Action, crossSlice: crossAction)
    }

    return (store, combinedAction)
  }

#else
  @MainActor
  public func createStoreWithSlices<Slice1: Slice, Slice2: Slice, CrossAction>(
    _ slice1: Slice1,
    _ slice2: Slice2,
    middleware: [any Middleware<CombinedState<Slice1.State, Slice2.State>>] = [],
    crossSliceAction: @escaping (StateSet<CombinedState<Slice1.State, Slice2.State>>) -> CrossAction
  ) -> (
    store: Store<CombinedState<Slice1.State, Slice2.State>>,
    action: CombinedAction<Slice1.Action, Slice2.Action, CrossAction>
  ) {
    let slice1Initial = slice1.create(StateSet<Slice1.State> { _ in })
    let slice2Initial = slice2.create(StateSet<Slice2.State> { _ in })
    let initialState = CombinedState(slice1: slice1Initial.state, slice2: slice2Initial.state)

    let (store, combinedAction) = createStore(
      initialState: initialState,
      middleware: middleware
    ) { set in
      let slice1Set = StateSet<Slice1.State> { updater in
        set { combinedState in
          updater(&combinedState.slice1)
        }
      }

      let slice2Set = StateSet<Slice2.State> { updater in
        set { combinedState in
          updater(&combinedState.slice2)
        }
      }

      let slice1Action = slice1.create(slice1Set).action
      let slice2Action = slice2.create(slice2Set).action
      let crossAction = crossSliceAction(set)

      return CombinedAction(slice1: slice1Action, slice2: slice2Action, crossSlice: crossAction)
    }

    return (store, combinedAction)
  }
#endif
