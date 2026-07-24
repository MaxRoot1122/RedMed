import SwiftUI

/// Lock screen shown while the owner's app content is gated behind Face ID
/// (or Touch ID / Optic ID / passcode, whatever the device has). This is the
/// screen the owner sees before RedMed's TabView appears.
///
/// Deliberately does NOT gate the emergency card a responder opens via
/// NFC/URL — see `BiometricGate` and `RedMedApp`'s `fullScreenCover`, which
/// is applied outside this view and is unaffected by it.
struct AppLockView: View {
    @Environment(\.layoutMetrics) private var layout

    let availability: BiometricGate.Availability
    let isAuthenticating: Bool
    let failed: Bool
    let onUnlock: () -> Void

    var body: some View {
        VStack(spacing: layout.spaceXL) {
            Spacer()

            BrandMark(size: .hero)

            VStack(spacing: layout.spaceSM) {
                Image(systemName: iconName)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
                    .padding(.bottom, layout.spaceXS)
                    .accessibilityHidden(true) // meaning is carried by the text below

                Text("RedMed is locked")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.ink)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, layout.spaceLG)
            }
            .accessibilityElement(children: .combine)

            if failed {
                Text("Couldn't verify it's you. Try again.")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
                    .accessibilityAddTraits(.updatesFrequently)
            }

            Spacer()

            Button {
                onUnlock()
            } label: {
                if isAuthenticating {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                } else {
                    Text(unlockLabel)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(PrimaryButtonStyle(prominent: true))
            .disabled(isAuthenticating)
            .padding(.horizontal, layout.spaceLG)
            .accessibilityLabel(isAuthenticating ? "Unlocking" : unlockLabel)
            .accessibilityHint("Double tap if RedMed didn't prompt automatically.")

            Text("Your medical profile stays on this device only. Anyone scanning your NFC card or emergency link still sees it — locking the app does not affect that.")
                .font(.caption2)
                .foregroundStyle(AppTheme.muted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, layout.spaceLG)
                .padding(.bottom, layout.spaceSM)
        }
        .padding(layout.space2XL)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.pageBg)
        .dynamicTypeSize(...DynamicTypeSize.accessibility3) // cap runaway scaling from breaking the button row
    }

    private var iconName: String {
        switch availability {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        case .passcodeOnly, .none: return "lock.fill"
        }
    }

    private var subtitle: String {
        switch availability {
        case .faceID: return "Use Face ID to open your medical profile."
        case .touchID: return "Use Touch ID to open your medical profile."
        case .opticID: return "Use Optic ID to open your medical profile."
        case .passcodeOnly: return "Enter your device passcode to open your medical profile."
        case .none: return "Tap to continue."
        }
    }

    private var unlockLabel: String {
        switch availability {
        case .faceID: return "Unlock with Face ID"
        case .touchID: return "Unlock with Touch ID"
        case .opticID: return "Unlock with Optic ID"
        case .passcodeOnly: return "Unlock with Passcode"
        case .none: return "Continue"
        }
    }
}

#Preview {
    AppLockView(availability: .faceID, isAuthenticating: false, failed: false, onUnlock: {})
        .withLayoutMetrics()
}
