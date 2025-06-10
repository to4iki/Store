import SwiftUI

@main
struct ExampleApp: App {
  var body: some Scene {
    WindowGroup {
      TabView {
        CounterView()
          .tabItem {
            Image(systemName: "number")
            Text("Counter")
          }

        BearFishView()
          .tabItem {
            Image(systemName: "pawprint.fill")
            Text("Bear & Fish")
          }
      }
    }
  }
}
