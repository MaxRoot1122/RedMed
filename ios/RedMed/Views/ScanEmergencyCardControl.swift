import SwiftUI

/// First-responder NFC path: read a bracelet chip → open hosted card in Safari.
/// Never touches `ProfileStore` — a scan of someone else's band must not
/// overwrite the owner's My ID.
struct ScanEmergencyCardControl: View {
    @Environment(\.layoutMetrics) private var layout

    var title: String = "Scan emergency bracelet"
    /// When true, uses the prominent red primary button (911 screen).
    var prominent: Bool = false
    /// Side-by-side with Call 911 — matched capsule height.
    var pairLayout: Bool = false

    @StateObject private var reader = NFCReader()

    var body: some View {
        VStack(spacing: pairLayout ? layout.spaceXS : layout.s(10)) {
            Group {
                if prominent {
                    Button(action: startScan) {
                        label
                            .frame(maxWidth: .infinity, maxHeight: pairLayout ? .infinity : nil)
                    }
                    .buttonStyle(PrimaryButtonStyle(
                        prominent: pairLayout ? false : true,
                        fixedHeight: pairLayout ? layout.emergencyPairButtonHeight : nil
                    ))
                } else {
                    Button(action: startScan) {
                        label
                            .frame(maxWidth: .infinity, maxHeight: pairLayout ? .infinity : nil)
                    }
                    .buttonStyle(SecondaryButtonStyle(
                        fixedHeight: pairLayout ? layout.emergencyPairButtonHeight : nil
                    ))
                }
            }
            .disabled(reader.isReading)

            if !reader.statusMessage.isEmpty {
                Text(reader.statusMessage)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(AppTheme.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var label: some View {
        Label(
            reader.isReading ? "Hold near bracelet…" : title,
            systemImage: "wave.3.right.circle.fill"
        )
    }

    private func startScan() {
        reader.readTag(
            alertMessage: "Hold your iPhone near the person's RedMed bracelet to open their emergency card."
        ) { _, urlString in
            Task { @MainActor in
                ProfileLinkBuilder.openHostedCard(urlString: urlString)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ScanEmergencyCardControl(prominent: true)
        ScanEmergencyCardControl()
    }
    .padding()
    .withLayoutMetrics()
}
