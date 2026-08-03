import SwiftUI

/// First-launch consent — artifact card layout.
struct UseConsentView: View {
    @Environment(\.layoutMetrics) private var layout

    let onAccept: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: layout.spaceXL) {
                    BrandMark(size: .hero, showTagline: true)
                        .padding(.top, layout.spaceLG)

                    EditSectionLabel(title: "Before you continue", isFirst: true)
                    EditCard {
                        VStack(alignment: .leading, spacing: layout.spaceMD) {
                            Text("RedMed stores your medical profile on this device only. Find 911 uses location while that screen is open. Nothing is sent to our servers.")
                                .font(layout.subheadlineFont(weight: .medium))
                                .foregroundStyle(AppTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(DesignPagePlacement.consentRegulatory)
                                .font(layout.captionFont(weight: .medium))
                                .foregroundStyle(AppTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)

                            Link("Privacy Policy", destination: URL(string: AppConfig.privacyPolicyURL)!)
                                .font(layout.subheadlineFont(weight: .semibold))
                                .foregroundStyle(AppTheme.accent)
                        }
                        .padding(layout.spaceLG)
                    }
                }
                .padding(.horizontal, layout.screenPad)
                .padding(.bottom, layout.spaceLG)
            }
            .screenAtmosphere()

            Button("Accept", action: onAccept)
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, layout.screenPad)
                .padding(.bottom, layout.screenBottom)
        }
    }
}

#Preview {
    UseConsentView(onAccept: {})
        .withLayoutMetrics()
}
