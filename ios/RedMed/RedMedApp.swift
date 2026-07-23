import SwiftUI

@main
struct RedMedApp: App {
    /// Set when the app is opened via a legacy `redmed://` deep link — holds THAT
    /// tag's decoded profile, separate from the owner's own ProfileStore.
    @State private var scannedProfile: MedicalProfile?
    @State private var showingScanned = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    // Own paired band: do not show emergency card on the owner's phone.
                    let linked = BraceletLinkStore.loadURL()
                    if isOwnPairedBand(opened: url.absoluteString, linked: linked) {
                        return
                    }
                    guard let profile = ProfileLinkBuilder.decodeProfile(fromURLString: url.absoluteString) else { return }
                    scannedProfile = profile
                    showingScanned = true
                }
                .fullScreenCover(isPresented: $showingScanned) {
                    ScannedCardView(profile: scannedProfile ?? MedicalProfile())
                        .withLayoutMetrics()
                }
        }
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
