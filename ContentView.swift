import SwiftUI

struct ContentView: View {
  @StateObject private var nfcManager = NFCManager()
  @State private var selectedTab = 0
  
  var body: some View {
    TabView(selection: $selectedTab) {
      // Setup Tab
      SetupView()
        .tabItem {
          Label("Setup", systemImage: "gearshape.fill")
        }
        .tag(0)
      
      // Emergency Card Tab
      EmergencyCardView()
        .tabItem {
          Label("Emergency", systemImage: "phone.badge.exclamationmark.fill")
        }
        .tag(1)
      
      // Help/Info Tab
      HelpView()
        .tabItem {
          Label("Help", systemImage: "questionmark.circle.fill")
        }
        .tag(2)
    }
    .accentColor(.red)
  }
}

#Preview {
  ContentView()
    .environmentObject(ProfileManager())
}
