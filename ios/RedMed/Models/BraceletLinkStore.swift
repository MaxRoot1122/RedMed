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

    /// Full chip URL embeds `#d=` medical payload — Keychain, not UserDefaults.
    @Published var deviceURL: String {
        didSet { Self.persistURL(deviceURL) }
    }

    enum Keys {
        static let name = "redMedBraceletDeviceName"
        static let url = "redMedBraceletDeviceURL"
        static let legacyPaired = "redMedBraceletPaired"
        static let urlAccount = "braceletDeviceURL"
    }

    private var nearbyTimer: Timer?

    init() {
        deviceName = UserDefaults.standard.string(forKey: Keys.name) ?? ""
        deviceURL = Self.loadURL()
        if deviceURL.isEmpty, UserDefaults.standard.bool(forKey: Keys.legacyPaired) {
            deviceName = deviceName.isEmpty ? "My bracelet" : deviceName
        }
    }

    /// Shared with `RedMedApp` deep-link ignore-own-band check.
    static func loadURL() -> String {
        if let data = KeychainStore.load(account: Keys.urlAccount),
           let url = String(data: data, encoding: .utf8),
           !url.isEmpty {
            return url
        }
        let legacy = UserDefaults.standard.string(forKey: Keys.url) ?? ""
        if !legacy.isEmpty {
            persistURL(legacy)
            UserDefaults.standard.removeObject(forKey: Keys.url)
        }
        return legacy
    }

    private static func persistURL(_ url: String) {
        if url.isEmpty {
            KeychainStore.delete(account: Keys.urlAccount)
        } else if let data = url.data(using: .utf8) {
            KeychainStore.save(data, account: Keys.urlAccount)
        }
        UserDefaults.standard.removeObject(forKey: Keys.url)
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
