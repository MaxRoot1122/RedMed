import Foundation

enum AppConfig {
    /// QR on packaging should point here — detects iOS vs Android and opens the right store.
    static let getStartedURL = "https://maxroot1122.github.io/RedMed/get.html"

    /// Update when the App Store listing is live (App Store Connect app ID).
    static let appStoreURL = "https://apps.apple.com/app/redmed/id0000000000"

    static let playStoreURL = "https://play.google.com/store/apps/details?id=local.redmed.app"

    /// Samsung Galaxy Store (same package id when published there).
    static let galaxyStoreURL = "https://apps.samsung.com/appquery/appDetail.as?appId=local.redmed.app"

    /// Huawei AppGallery — replace C000000000 with your listing id when live.
    static let appGalleryURL = "https://appgallery.huawei.com/#/app/C000000000"
    static let appGalleryIntentURL = "appmarket://details?id=local.redmed.app"

    static let amazonStoreURL = "https://www.amazon.com/gp/mas/dl/android?p=local.redmed.app"

    /// Canonical HTTPS card page written to NFC tags (`#d=…` profile on chip).
    /// Points at the hosted root `index.html` — any phone that taps opens that
    /// file in a browser (Swift does not embed the emergency card). Keep in
    /// sync with `config/canonical-url` via `scripts/sync-canonical-url.sh`.
    static let medicalCardBaseURL = "https://maxroot1122.github.io/RedMed/index.html"

    /// Registered in Info.plist for marketing deep links and legacy tags written
    /// before the universal HTTPS switch — not used for new tag writes.
    static let legacyAppSchemeBaseURL = "redmed://card"

    static let privacyPolicyURL = "https://maxroot1122.github.io/RedMed/privacy-policy.html"
}
