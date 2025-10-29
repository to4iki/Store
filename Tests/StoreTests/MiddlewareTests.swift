import Testing

@testable import Store

@Suite
struct MiddlewareTests {
  struct TestState: Sendable {
    var count: Int = 0
  }

  @MainActor
  @Test
  func middlewareProtocol() {
    struct IncrementMiddleware: Middleware {
      func apply(currentState: TestState, next: StateSet<TestState>) -> StateSet<TestState> {
        StateSet<TestState> { updater in
          var newState = currentState
          updater(&newState)
          newState.count += 1
          next { state in
            state = newState
          }
        }
      }
    }

    let middleware = IncrementMiddleware()
    let initialState = TestState(count: 0)

    var finalState = initialState
    let stateSet = middleware.apply(
      currentState: initialState,
      next: StateSet<TestState> { updater in
        var state = initialState
        updater(&state)
        finalState = state
      }
    )

    stateSet { state in
      state.count = 1
    }

    #expect(finalState.count == 2)
  }
}
