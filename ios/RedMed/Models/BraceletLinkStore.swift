import Foundation

/// Tracks the owner's linked bracelet (device name + chip URL) and a short
/// "nearby" pulse after a successful NFC read/write — iOS has no silent
/// background tag polling like Web NFC scan on Android Chrome.
@MainActor
final class BraceletLinkStore: ObservableObject {
    @Published private(set) var isNearby = false

    @Published var deviceName: String {
        didSet { UserDefaults.standard.set(deviceName, forKey: Keys.name) }
    }

    @Published var deviceURL: String {
        didSet { UserDefaults.standard.set(deviceURL, forKey: Keys.url) }
    }

    private enum Keys {
        static let name = "redMedBraceletDeviceName"
        static let url = "redMedBraceletDeviceURL"
        static let legacyPaired = "redMedBraceletPaired"
    }

    private var nearbyTimer: Timer?

    init() {
        deviceName = UserDefaults.standard.string(forKey: Keys.name) ?? ""
        deviceURL = UserDefaults.standard.string(forKey: Keys.url) ?? ""
        if deviceURL.isEmpty, UserDefaults.standard.bool(forKey: Keys.legacyPaired) {
            deviceName = deviceName.isEmpty ? "My bracelet" : deviceName
        }
    }

    var isLinked: Bool { !deviceURL.isEmpty }

    var headerTitle: String {
        isLinked && !deviceName.isEmpty ? deviceName : "RedMed"
    }

    func link(name: String, url: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        deviceName = trimmed.isEmpty ? "My bracelet" : trimmed
        deviceURL = url
        UserDefaults.standard.set(true, forKey: Keys.legacyPaired)
        markNearby()
    }

    func updateName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isLinked else { return }
        deviceName = trimmed.isEmpty ? "My bracelet" : trimmed
    }

    func clear() {
        deviceName = ""
        deviceURL = ""
        isNearby = false
        nearbyTimer?.invalidate()
        nearbyTimer = nil
        UserDefaults.standard.removeObject(forKey: Keys.legacyPaired)
    }

    func markNearby() {
        isNearby = true
        nearbyTimer?.invalidate()
        nearbyTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            Task { @MainActor in self?.isNearby = false }
        }
    }

    func matches(url: String) -> Bool {
        !deviceURL.isEmpty && deviceURL == url
    }
}
