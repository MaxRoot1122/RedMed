import SwiftUI

struct ContentView: View {
    @StateObject private var store = ProfileStore()
    @StateObject private var braceletLink = BraceletLinkStore()
    @State private var tab: AppTab = .myid
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            switch tab {
            case .myid: MyIDView(tab: $tab)
            case .emergency: LocationView()
            case .aid: BasicAidView()
            case .nfc: WriteTagView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ArtifactCustomTabBar(tab: $tab)
        }
        .environmentObject(store)
        .environmentObject(braceletLink)
        .preferredColorScheme(.light)
        .onReceive(NotificationCenter.default.publisher(for: .redMedOpenOwnerTab)) { note in
            guard let raw = note.object as? String else { return }
            switch raw {
            case "911": tab = .emergency
            case "aid": tab = .aid
            case "nfc": tab = .nfc
            default: tab = .myid
            }
        }
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
