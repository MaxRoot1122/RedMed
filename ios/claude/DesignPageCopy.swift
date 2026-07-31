import Foundation

/// Copy extracted from `ios/Design.pdf` pages 1–7.
/// Source of truth for deck text — views read from here, not inline strings.
enum DesignPageCopy {

    // MARK: - Shared types

    struct FlowStep: Identifiable {
        let id: String
        let label: String
        let title: String
        let detail: String
    }

    struct CompareRow: Identifiable {
        let id: String
        let feature: String
        let redMed: Bool
        let qrBand: Bool
        /// Apple Health / locked iPhone — owner product lane.
        let appleHealth: Bool
        /// Android — reader-only; no owner app.
        let walletID: Bool
    }

    struct ValueCard: Identifiable {
        let id: String
        let title: String
        let body: String
    }

    struct MarketStat: Identifiable {
        let id: String
        let value: String
        let label: String
        let detail: String
    }

    // MARK: - Page 1 — brand

    enum Page1 {
        static let eyebrow = "Next generation solutions"
        static let tagline = "Reducing Human Suffering"
        static let lead = "A passive NFC medical ID, built for the one moment a QR code can't handle."
    }

    // MARK: - Page 2 — problem

    enum Page2 {
        static let eyebrow = "The problem"
        static let title = "Fails You When You Need It Most"
        static let bullets = [
            "QR codes need clean light — never work in the dark, rain, or blood.",
            "Most hide the code inside the band, under an unconscious wrist.",
            "Apple Health needs the right iPhone, unlocked, and a responder who knows to look.",
            "Android has no lock-screen medical ID — Google Health isn't there when a stranger taps."
        ]
    }

    // MARK: - Page 3 — solution

    enum Page3 {
        static let eyebrow = "Tap the band"
        static let title = "A Tap, Not a Scan"
        static let lead = "Any phone taps the band — profile opens instantly, no app."
        static let frictionLine = "Two Screens. One Tap. Zero Friction."
        static let detail = "First aid and emergency contacts, with 911 as the obvious next step. No battery, no server, no breach — it just works, forever."

        static let flowSteps: [FlowStep] = [
            FlowStep(
                id: "owner-fill",
                label: "Setup — iPhone owner",
                title: "Fill My ID",
                detail: "Name, blood type, allergies, conditions, and emergency contacts. Save once on this iPhone."
            ),
            FlowStep(
                id: "owner-write",
                label: "Write — iPhone owner",
                title: "Program the band",
                detail: "CoreNFC writes your hosted card link to the chip. One tap setup — no Android owner app, by design."
            ),
            FlowStep(
                id: "responder-tap",
                label: "Tap — any reader",
                title: "iPhone or Android",
                detail: "Call 911 and critical info open in the browser. iPhone: instant. Android: Chrome, no app — eh, but it works."
            )
        ]
    }

    // MARK: - Page 4 — comparison (Apple product vs Android)

    enum Page4 {
        static let eyebrow = "The competitive landscape"
        static let title = "Faster Than Anything Else on the Market"
        static let columns = ("RedMed", "QR", "Apple", "Android")

        static let rows: [CompareRow] = [
            CompareRow(id: "dark-rain", feature: "Works in dark or rain", redMed: true, qrBand: false, appleHealth: false, walletID: true),
            CompareRow(id: "no-app-reader", feature: "No app for the reader", redMed: true, qrBand: true, appleHealth: false, walletID: true),
            CompareRow(id: "owner-setup", feature: "Program band on your phone", redMed: true, qrBand: false, appleHealth: false, walletID: false),
            CompareRow(id: "nfc-write", feature: "Write chip once (CoreNFC)", redMed: true, qrBand: false, appleHealth: false, walletID: false),
            CompareRow(id: "any-reader-phone", feature: "Any phone reads the band", redMed: true, qrBand: true, appleHealth: false, walletID: true),
            CompareRow(id: "on-wrist", feature: "Always on the wrist", redMed: true, qrBand: true, appleHealth: false, walletID: false)
        ]

        /// Android readers tap → browser card. No owner app — fine, not the product.
        static let androidReaderNote = "Android readers: tap opens your card in Chrome. No RedMed install — works, just not fancy."
    }

    // MARK: - Page 5 — privacy

    enum Page5 {
        static let eyebrow = "Regulatory primer"
        static let title = "Built Outside HIPAA's Reach — By Design"
        static let bullets = [
            "RedMed is not a HIPAA covered entity or business associate — direct-to-consumer wearables generally fall outside HIPAA, and with no server there is no centralized PHI store to breach.",
            "Still in scope for the FTC Health Breach Notification Rule and state health-data laws. Local-only architecture minimizes exposure.",
            "Tag data is intentionally unencrypted so any responder's phone can read it instantly — the same tradeoff every medical ID bracelet makes, disclosed up front."
        ]
        /// Short form for the first-launch consent sheet.
        static let consentSummary = "RedMed is not a HIPAA covered entity. Tag data is intentionally unencrypted so any phone can read it in an emergency — the same tradeoff every medical ID bracelet makes."
    }

    // MARK: - Page 6 — product model

    enum Page6 {
        static let eyebrow = "No subscriptions"
        static let title = "One Product, One Payment, No Servers to Run"

        static let valueCards: [ValueCard] = [
            ValueCard(
                id: "one-purchase",
                title: "One band, one purchase",
                body: "No subscription or recurring fee. Buy the band, program it once, wear it."
            ),
            ValueCard(
                id: "no-servers",
                title: "No servers to run",
                body: "Your profile lives on the chip and this phone. RedMed has no backend to maintain or breach."
            ),
            ValueCard(
                id: "replace",
                title: "Replace, don't repair",
                body: "Profile changed? Re-write the band from the NFC tab. Lost band? Program a new one."
            ),
            ValueCard(
                id: "passive",
                title: "Passive forever",
                body: "NTAG chip — no battery, no charging, no pairing. It works as long as it is worn."
            )
        ]
    }

    // MARK: - Page 7 — market

    enum Page7 {
        static let eyebrow = "The market"
        static let title = "A Fast-Growing, Underserved Market"

        static let stats: [MarketStat] = [
            MarketStat(
                id: "bracelets",
                value: "$1.4B",
                label: "Medical ID bracelets",
                detail: "Global market projected by 2033 — the category RedMed sits in."
            ),
            MarketStat(
                id: "alert-systems",
                value: "$28.6B",
                label: "Medical alert systems",
                detail: "Broader alert market growing ~11% annually — mostly subscription hardware."
            ),
            MarketStat(
                id: "smartwatch",
                value: "~2.3M",
                label: "Daily smartwatch users",
                detail: "U.S. consumers who already carry a tap-ready device every day."
            )
        ]
    }
}
