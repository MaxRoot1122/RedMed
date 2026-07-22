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
                    guard let profile = ProfileLinkBuilder.decodeProfile(fromURLString: url.absoluteString) else { return }
                    scannedProfile = profile
                    showingScanned = true
                }
                .fullScreenCover(isPresented: $showingScanned) {
                    ScannedCardView(profile: scannedProfile ?? MedicalProfile())
                }
        }
    }
}
