import SwiftUI

/// First-launch consent — mirrors the web app's one-time banner so App Review
/// sees the same privacy posture as the hosted card page.
struct UseConsentView: View {
    @Environment(\.layoutMetrics) private var layout

    let onAccept: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: layout.spaceXL) {
                BrandMark(size: .hero)
                    .padding(.top, layout.spaceSM)

                Text("Before you continue")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.ink)

                Text("RedMed stores your medical profile on this device only. Find 911 uses location while that screen is open. Nothing is sent to our servers.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Link("Privacy Policy", destination: URL(string: AppConfig.privacyPolicyURL)!)
                    .font(.subheadline.weight(.semibold))

                Button("Accept", action: onAccept)
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding(layout.space2XL)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.visible, axes: .vertical)
        .background(AppTheme.pageBg)
    }
}

#Preview {
    UseConsentView(onAccept: {})
        .withLayoutMetrics()
}
