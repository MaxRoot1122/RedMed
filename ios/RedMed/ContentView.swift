import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var store = ProfileStore()
    @StateObject private var braceletLink = BraceletLinkStore()
    @AppStorage("redMedUseConsent") private var useConsentAccepted = false

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        appearance.shadowColor = UIColor(red: 0.91, green: 0.92, blue: 0.93, alpha: 1)
        appearance.shadowImage = nil
        let item = UITabBarItemAppearance()
        let muted = UIColor(red: 0.373, green: 0.388, blue: 0.408, alpha: 1)
        item.normal.iconColor = muted
        item.normal.titleTextAttributes = [
            .foregroundColor: muted,
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        item.selected.iconColor = UIColor(red: 0.882, green: 0.114, blue: 0.282, alpha: 1)
        item.selected.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.882, green: 0.114, blue: 0.282, alpha: 1),
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]
        appearance.stackedLayoutAppearance = item
        appearance.inlineLayoutAppearance = item
        appearance.compactInlineLayoutAppearance = item
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = false
    }

    var body: some View {
        TabView {
            MyIDView()
                .tabItem { Label("RedMed", systemImage: "person.crop.circle.fill") }

            LocationView()
                .tabItem { Label("911", systemImage: "phone.fill") }

            BasicAidView()
                .tabItem { Label("Aid", systemImage: "cross.case.fill") }

            WriteTagView()
                .tabItem { Label("NFC", systemImage: "wave.3.right.circle.fill") }
        }
        .environmentObject(store)
        .environmentObject(braceletLink)
        .tint(AppTheme.accent)
        .preferredColorScheme(.light)
        .fullScreenCover(isPresented: Binding(
            get: { !useConsentAccepted },
            set: { _ in }
        )) {
            UseConsentView {
                useConsentAccepted = true
            }
        }
        .withLayoutMetrics()
    }
}

#Preview {
    ContentView()
}
