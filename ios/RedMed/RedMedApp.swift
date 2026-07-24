import SwiftUI

extension Notification.Name {
    /// Posted when a Universal Link / deep link asks for an owner tab (`aid`, `911`, or empty → My ID).
    static let redMedOpenOwnerTab = Notification.Name("redMedOpenOwnerTab")
}

@main
struct RedMedApp: App {
    /// Bracelet tap / Universal Link `#d=` — THAT tag's profile, not the owner's.
    @State private var scannedProfile: MedicalProfile?
    @State private var showingScanned = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    guard let url = activity.webpageURL else { return }
                    handleIncomingURL(url)
                }
                .fullScreenCover(isPresented: $showingScanned) {
                    ScannedCardView(profile: scannedProfile ?? MedicalProfile())
                        .withLayoutMetrics()
                }
        }
    }

    /// HTTPS card URLs (Universal Links) and legacy `redmed://` both land here.
    private func handleIncomingURL(_ url: URL) {
        let urlString = url.absoluteString

        // Emergency card payload on the chip / shared link.
        if urlString.contains("#d=") || urlString.contains("d=") {
            let linked = BraceletLinkStore.loadURL()
            if isOwnPairedBand(opened: urlString, linked: linked) {
                NotificationCenter.default.post(name: .redMedOpenOwnerTab, object: "myid")
                return
            }
            guard let profile = ProfileLinkBuilder.decodeProfile(fromURLString: urlString) else { return }
            scannedProfile = profile
            showingScanned = true
            return
        }

        // Owner deep links: …/index.html#911 etc. (canonical host from AppConfig).
        let tab = ownerTab(from: url)
        NotificationCenter.default.post(name: .redMedOpenOwnerTab, object: tab)
    }

    private func ownerTab(from url: URL) -> String {
        let fragment = (url.fragment ?? "").lowercased()
        if fragment == "911" || fragment.hasPrefix("911") { return "911" }
        if fragment == "aid" || fragment.hasPrefix("aid") { return "aid" }
        return "myid"
    }

    private func isOwnPairedBand(opened: String, linked: String) -> Bool {
        guard !linked.isEmpty else { return false }
        if opened == linked { return true }
        guard let openHash = opened.split(separator: "#").last,
              let linkHash = linked.split(separator: "#").last,
              openHash.hasPrefix("d="),
              linkHash.hasPrefix("d=") else { return false }
        return openHash == linkHash
    }
}
