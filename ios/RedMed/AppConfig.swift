import Foundation

enum AppConfig {
    /// Packaging QR / get-started landing. Product is iOS-only — App Store.
    static let getStartedURL = "https://apps.apple.com/app/redmed/id0000000000"

    /// Update when the App Store listing is live (App Store Connect app ID).
    static let appStoreURL = "https://apps.apple.com/app/redmed/id0000000000"

    /// HTTPS URI written to passive NFC bracelets by the RedMed iPhone app
    /// (`#d=…` profile on chip). Any iPhone tap opens Safari with the hosted
    /// emergency card — no App Store install for responders. In-app NFC scan
    /// and `redmed://card` deep links still decode into native `ScannedCardView`.
    static let medicalCardBaseURL = "https://maxroot1122.github.io/RedMed/card/"

    /// Older bracelets may carry `redmed://card`; in-app decode still accepts
    /// `#d=` from those and from this HTTPS path.
    static let legacyHostedCardBaseURL = "https://maxroot1122.github.io/RedMed/card/"

    static let privacyPolicyURL = "https://maxroot1122.github.io/RedMed/privacy-policy.html"
}
