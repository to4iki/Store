import Foundation
import Testing

@testable import Store

@Suite
struct LoggingMiddlewareTests {
  struct TestState: Sendable {
    var count: Int = 0
  }

  final class LogCapture: @unchecked Sendable {
    private let lock = NSLock()
    private var _logs: [String] = []

    func append(_ message: String) {
      lock.lock()
      _logs.append(message)
      lock.unlock()
    }

    var logs: [String] {
      lock.lock()
      defer { lock.unlock() }
      return _logs
    }
  }

  @MainActor
  @Test
  func defaultConfiguration_logsBothBeforeAndAfter() {
    let capture = LogCapture()
    let middleware = LoggingMiddleware<TestState>(handler: { capture.append($0) })
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
      state.count = 5
    }

    #expect(finalState.count == 5)
    #expect(capture.logs.count == 2)
    #expect(capture.logs[0].contains("Before"))
    #expect(capture.logs[1].contains("After"))
  }

  @MainActor
  @Test
  func logBeforeOnly() {
    let capture = LogCapture()
    let middleware = LoggingMiddleware<TestState>(
      handler: { capture.append($0) },
      logBefore: true,
      logAfter: false
    )
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
      state.count = 3
    }

    #expect(finalState.count == 3)
    #expect(capture.logs.count == 1)
    #expect(capture.logs[0].contains("Before"))
  }

  @MainActor
  @Test
  func logAfterOnly() {
    let capture = LogCapture()
    let middleware = LoggingMiddleware<TestState>(
      handler: { capture.append($0) },
      logBefore: false,
      logAfter: true
    )
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
      state.count = 7
    }

    #expect(finalState.count == 7)
    #expect(capture.logs.count == 1)
    #expect(capture.logs[0].contains("After"))
  }

  @MainActor
  @Test
  func noLogging() {
    let capture = LogCapture()
    let middleware = LoggingMiddleware<TestState>(
      handler: { capture.append($0) },
      logBefore: false,
      logAfter: false
    )
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

    #expect(finalState.count == 1)
    #expect(capture.logs.isEmpty)
  }

  @MainActor
  @Test
  func customStateTransform() {
    let capture = LogCapture()
    let middleware = LoggingMiddleware<TestState>(
      handler: { capture.append($0) },
      stateTransform: { "count=\($0.count)" }
    )
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
      state.count = 10
    }

    #expect(finalState.count == 10)
    #expect(capture.logs[0].contains("count=0"))
    #expect(capture.logs[1].contains("count=10"))
  }

  @MainActor
  @Test
  func defaultStateTransform_usesStringDescribing() {
    let capture = LogCapture()
    let middleware = LoggingMiddleware<TestState>(handler: { capture.append($0) })
    let initialState = TestState(count: 42)

    let stateSet = middleware.apply(
      currentState: initialState,
      next: StateSet<TestState> { updater in
        var state = initialState
        updater(&state)
      }
    )

    stateSet { state in
      state.count = 99
    }

    #expect(capture.logs[0].contains("TestState(count: 42)"))
    #expect(capture.logs[1].contains("TestState(count: 99)"))
  }
}
