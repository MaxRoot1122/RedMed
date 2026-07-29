import SwiftUI

@main
struct RedMedApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(ProfileManager())
    }
  }
}
