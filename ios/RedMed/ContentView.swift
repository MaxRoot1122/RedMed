import SwiftUI

struct ContentView: View {
    @Environment(\.layoutMetrics) private var layout
    @StateObject private var store = ProfileStore()
    @StateObject private var braceletLink = BraceletLinkStore()
    @State private var selectedTab: OwnerTab = .myID
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .myID:
                    MyIDView(selectedTab: $selectedTab)
                case .find911:
                    LocationView()
                case .aid:
                    BasicAidView()
                case .nfc:
                    WriteTagView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, layout.customTabBarReserve)

            CustomTabBar(tab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
        .environmentObject(store)
        .environmentObject(braceletLink)
        .tint(AppTheme.accent)
        .preferredColorScheme(.light)
        .onReceive(NotificationCenter.default.publisher(for: .redMedOpenOwnerTab)) { note in
            guard let raw = note.object as? String else { return }
            switch raw {
            case "911": selectedTab = .find911
            case "aid": selectedTab = .aid
            case "nfc": selectedTab = .nfc
            default: selectedTab = .myID
            }
        }
        .withLayoutMetrics()
        .onAppear {
            braceletLink.promotePostPairingGraceIfEligible()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active: braceletLink.promotePostPairingGraceIfEligible()
            case .background: braceletLink.noteAppDidBackground()
            default: break
            }
        }
    }

}

#Preview {
    ContentView()
}
