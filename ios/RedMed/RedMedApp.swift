import SwiftUI

extension Notification.Name {
    /// Posted when a Universal Link / deep link asks for an owner tab (`aid`, `911`, or empty → My ID).
    static let redMedOpenOwnerTab = Notification.Name("redMedOpenOwnerTab")
}

@main
struct RedMedApp: App {
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
        }
    }

    /// Owner deep links (`redmed://`, #911, #aid). Bracelet `#d=` opens Safari — not the app.
    private func handleIncomingURL(_ url: URL) {
        let urlString = url.absoluteString

        if urlString.contains("#d=") || urlString.contains("d=") {
            let linked = BraceletLinkStore.loadURL()
            if isOwnPairedBand(opened: urlString, linked: linked) {
                NotificationCenter.default.post(name: .redMedOpenOwnerTab, object: "myid")
                return
            }
            Task { @MainActor in
                ProfileLinkBuilder.openHostedCard(urlString: urlString)
            }
            return
        }

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
