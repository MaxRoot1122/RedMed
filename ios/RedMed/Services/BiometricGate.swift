import Foundation
import LocalAuthentication

/// Local-only biometric gate for editing the owner's medical profile on My ID.
///
/// UI/tamper gate, not encryption — profile is already Keychain-protected.
/// Does NOT gate the emergency card (`ScannedCardView`) or first-time setup
/// before a profile exists on this device.
enum BiometricGate {

    enum Availability: Equatable {
        case faceID
        case touchID
        case opticID
        case passcodeOnly
        case none
    }

    static func availability() -> Availability {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID: return .faceID
            case .touchID: return .touchID
            case .opticID: return .opticID
            default: return .passcodeOnly
            }
        }
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            return .passcodeOnly
        }
        return .none
    }

    /// Biometrics with device-passcode fallback so the owner is never locked out.
    static func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        context.localizedFallbackTitle = "Enter Passcode"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            return true
        }

        return await withCheckedContinuation { continuation in
            context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            ) { success, _ in
                continuation.resume(returning: success)
            }
        }
    }
}
