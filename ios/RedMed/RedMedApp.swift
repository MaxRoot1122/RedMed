import SwiftUI

@main
struct RedMedApp: App {
    /// Set when the app opens a bracelet URL (`redmed://` legacy or HTTPS `#d=`)
    /// — holds THAT tag's decoded profile, separate from the owner's ProfileStore.
    @State private var scannedProfile: MedicalProfile?
    @State private var showingScanned = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    presentScannedCard(from: url.absoluteString)
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    // Universal Links path (when associated domains are live).
                    guard let url = activity.webpageURL else { return }
                    presentScannedCard(from: url.absoluteString)
                }
                .fullScreenCover(isPresented: $showingScanned) {
                    ScannedCardView(profile: scannedProfile ?? MedicalProfile())
                        .withLayoutMetrics()
                }
        }
    }

    /// Decode `#d=` from any scheme and show the first-responder card.
    /// Own paired band is skipped so the owner's phone stays on My ID.
    private func presentScannedCard(from urlString: String) {
        let linked = BraceletLinkStore.loadURL()
        if isOwnPairedBand(opened: urlString, linked: linked) {
            return
        }
        guard let profile = ProfileLinkBuilder.decodeProfile(fromURLString: urlString) else { return }
        scannedProfile = profile
        showingScanned = true
    }

    /// Match full URL or shared `#d=` payload so scheme differences still count as own band.
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
