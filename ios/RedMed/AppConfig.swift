import Foundation

enum AppConfig {
    /// Packaging QR / band-setup landing (iPhone → App Store). Keep in sync with `get.html`.
    static let getStartedURL = "https://maxroot1122.github.io/RedMed/get.html"

    /// Update when the App Store listing is live (App Store Connect app ID).
    static let appStoreURL = "https://apps.apple.com/app/redmed/id0000000000"

    /// HTTPS URI written to passive NFC bands (CoreNFC). `#d=…` on chip.
    /// Tap the band → any smartphone opens the hosted emergency card in the browser.
    /// No app for readers. In-app NFC scan and `redmed://card` decode to `ScannedCardView`.
    static let medicalCardBaseURL = "https://maxroot1122.github.io/RedMed/card/"

    /// Older bands may carry `redmed://card`; in-app decode still accepts `#d=` from those.
    static let legacyHostedCardBaseURL = "https://maxroot1122.github.io/RedMed/card/"

    static let privacyPolicyURL = "https://maxroot1122.github.io/RedMed/privacy-policy.html"
}
