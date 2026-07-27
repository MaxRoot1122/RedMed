import Foundation

enum AppConfig {
    /// Packaging QR / get-started landing. Product is iOS-only — App Store.
    static let getStartedURL = "https://apps.apple.com/app/redmed/id0000000000"

    /// Update when the App Store listing is live (App Store Connect app ID).
    static let appStoreURL = "https://apps.apple.com/app/redmed/id0000000000"

    /// Canonical URI written to NFC tags (`#d=…` profile on chip).
    /// Opens in the RedMed iOS app via the registered `redmed` URL scheme.
    /// Emergency card UI is native `ScannedCardView` — not a web page.
    static let medicalCardBaseURL = "redmed://card"

    /// Older bracelets may still carry an HTTPS Pages URL; the app still
    /// decodes `#d=` from those when scanned in-app. Points at the minimal
    /// offline-cacheable card/, not the full owner web app (index.html).
    static let legacyHostedCardBaseURL = "https://maxroot1122.github.io/RedMed/card/"

    static let privacyPolicyURL = "https://maxroot1122.github.io/RedMed/privacy-policy.html"
}
