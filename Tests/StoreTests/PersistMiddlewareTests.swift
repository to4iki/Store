import Foundation
import Testing

@testable import Store

@Suite
struct PersistMiddlewareTests {
  struct TestState: Codable, Sendable, Equatable {
    var count: Int = 0
    var name: String = ""
  }

  /// In-memory storage for testing
  final class InMemoryStorage: PersistStorage, @unchecked Sendable {
    var data: [String: Data] = [:]

    func load(key: String) -> Data? {
      data[key]
    }

    func save(key: String, data: Data) {
      self.data[key] = data
    }

    func remove(key: String) {
      data.removeValue(forKey: key)
    }
  }

  @MainActor
  @Test
  func savesStateAfterUpdate() {
    let storage = InMemoryStorage()
    let middleware = PersistMiddleware<TestState>(key: "test", storage: storage)
    let initialState = TestState(count: 0, name: "")

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
      state.count = 42
      state.name = "hello"
    }

    #expect(finalState.count == 42)
    #expect(finalState.name == "hello")

    // Verify data was persisted
    let savedData = storage.load(key: "test")
    #expect(savedData != nil)

    let decoded = try! JSONDecoder().decode(TestState.self, from: savedData!)
    #expect(decoded.count == 42)
    #expect(decoded.name == "hello")
  }

  @MainActor
  @Test
  func loadStateRestoresFromStorage() {
    let storage = InMemoryStorage()
    let state = TestState(count: 99, name: "persisted")
    let data = try! JSONEncoder().encode(state)
    storage.save(key: "test", data: data)

    let loaded = PersistMiddleware<TestState>.loadState(
      key: "test",
      storage: storage,
      fallback: TestState()
    )

    #expect(loaded.count == 99)
    #expect(loaded.name == "persisted")
  }

  @MainActor
  @Test
  func loadStateReturnsFallbackWhenNoData() {
    let storage = InMemoryStorage()
    let fallback = TestState(count: 0, name: "default")

    let loaded = PersistMiddleware<TestState>.loadState(
      key: "missing",
      storage: storage,
      fallback: fallback
    )

    #expect(loaded == fallback)
  }

  @MainActor
  @Test
  func loadStateReturnsFallbackWhenDataIsCorrupted() {
    let storage = InMemoryStorage()
    storage.save(key: "test", data: Data("invalid json".utf8))

    let fallback = TestState(count: 0, name: "default")
    let loaded = PersistMiddleware<TestState>.loadState(
      key: "test",
      storage: storage,
      fallback: fallback
    )

    #expect(loaded == fallback)
  }

  @MainActor
  @Test
  func worksWithCreateStore() {
    let storage = InMemoryStorage()

    struct Actions {
      let setCount: (Int) -> Void
    }

    let middleware = PersistMiddleware<TestState>(key: "store-test", storage: storage)
    let (store, actions) = createStore(
      initialState: TestState(),
      middleware: [middleware]
    ) { set in
      Actions(
        setCount: { value in set { $0.count = value } }
      )
    }

    actions.setCount(10)
    #expect(store.state.count == 10)

    // Verify persisted
    let savedData = storage.load(key: "store-test")
    #expect(savedData != nil)
    let decoded = try! JSONDecoder().decode(TestState.self, from: savedData!)
    #expect(decoded.count == 10)
  }
}
