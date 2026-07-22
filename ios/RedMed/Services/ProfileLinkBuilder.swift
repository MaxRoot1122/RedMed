import Foundation

/// Builds the same kind of link the web app (index.html) generates: the
/// profile JSON, base64url-encoded, appended after "#d=". Any NFC tag
/// written by this app opens correctly in the web app's view mode, and
/// vice versa.
enum ProfileLinkBuilder {

    static func buildURL(profile: MedicalProfile, baseURL: String) -> URL? {
        var stamped = profile
        stamped.updated = ISO8601DateFormatter().string(from: Date())

        guard let jsonData = try? JSONEncoder().encode(stamped) else { return nil }
        let encoded = base64url(jsonData)
        return URL(string: baseURL + "#d=" + encoded)
    }

    /// Mirrors index.html's on-screen guidance about which NFC tag size is needed.
    /// Counts the full NDEF URI (base URL + `#d=` + payload) — tag capacity is
    /// consumed by the whole string written to the chip, not just the profile.
    static func capacityNote(
        for profile: MedicalProfile,
        baseURL: String = AppConfig.medicalCardBaseURL
    ) -> (text: String, warn: Bool) {
        guard let jsonData = try? JSONEncoder().encode(profile) else {
            return ("", false)
        }
        let encoded = base64url(jsonData)
        let byteCount = (baseURL + "#d=" + encoded).utf8.count

        if byteCount > 850 {
            return ("\(byteCount) bytes on tag — too large for most NFC tags. Shorten your entries or use an NTAG216 (~888 bytes).", true)
        } else if byteCount > 480 {
            return ("\(byteCount) bytes on tag — needs an NTAG216.", false)
        } else if byteCount > 140 {
            return ("\(byteCount) bytes on tag — needs an NTAG215 or NTAG216.", false)
        } else {
            return ("\(byteCount) bytes on tag — fits any standard NFC tag (NTAG213+).", false)
        }
    }

    /// Reverse of buildURL — pulls the "#d=" fragment out of a URL string
    /// (whether it came from this device's own tag or the web app's) and
    /// decodes it straight into a profile. Pure string/JSON decoding, no
    /// network call: reading a tag never needs the hosted page to be
    /// reachable, only the bytes physically on the tag.
    static func decodeProfile(fromURLString urlString: String) -> MedicalProfile? {
        guard let range = urlString.range(of: "#d=") else { return nil }
        let encoded = String(urlString[range.upperBound...])
        guard let data = base64urlDecode(encoded) else { return nil }
        return try? JSONDecoder().decode(MedicalProfile.self, from: data)
    }

    private static func base64url(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private static func base64urlDecode(_ encoded: String) -> Data? {
        var base64 = encoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        return Data(base64Encoded: base64)
    }
}
