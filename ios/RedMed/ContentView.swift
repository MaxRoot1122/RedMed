import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var store = ProfileStore()
    @StateObject private var braceletLink = BraceletLinkStore()
    @State private var selectedTab: AppTab = .find911
    @Environment(\.scenePhase) private var scenePhase

    private enum AppTab: Hashable {
        case myID, find911, aid, nfc
    }

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.redMedPageBg
        appearance.shadowColor = UIColor.redMedLine
        appearance.shadowImage = nil
        let item = UITabBarItemAppearance()
        item.normal.iconColor = UIColor.redMedMuted
        item.normal.titleTextAttributes = [
            .foregroundColor: UIColor.redMedMuted,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        item.selected.iconColor = UIColor.redMedAccent
        item.selected.titleTextAttributes = [
            .foregroundColor: UIColor.redMedAccent,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        item.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -1)
        item.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -1)
        appearance.stackedLayoutAppearance = item
        appearance.inlineLayoutAppearance = item
        appearance.compactInlineLayoutAppearance = item
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        if #available(iOS 26.0, *) {
            UITabBar.appearance().isHidden = false
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            MyIDView()
                .tabItem { Label("RedMed", systemImage: "person.crop.circle.fill") }
                .tag(AppTab.myID)

            LocationView()
                .tabItem { Label("911", systemImage: "phone.fill") }
                .tag(AppTab.find911)

            BasicAidView()
                .tabItem { Label("Aid", systemImage: "cross.case.fill") }
                .tag(AppTab.aid)

            WriteTagView()
                .tabItem { Label("NFC", systemImage: "wave.3.right.circle.fill") }
                .tag(AppTab.nfc)
        }
        .modifier(TabBarBehaviorModifier())
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
            // Cold launch after pairing+backgrounding (e.g. kill & relaunch):
            // there's no scenePhase *change* to observe for the app's own
            // first activation, so check once on appear too.
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

/// iOS 26+ floating/minimized tab bars change height while scrolling — keep a stable bar.
private struct TabBarBehaviorModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .tabBarMinimizeBehavior(.never)
                .toolbarBackground(.visible, for: .tabBar)
        } else {
            content
        }
    }
}
