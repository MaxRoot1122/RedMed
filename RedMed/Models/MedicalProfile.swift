import Foundation

/// Medical profile fields written to the band chip (`#d=` JSON): name, dob,
/// blood, donor, allergies, meds, conditions, contacts, updated.

struct EmergencyContact: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var name: String = ""
    var rel: String = ""
    var phone: String = ""

    enum CodingKeys: String, CodingKey {
        case name, rel, phone
    }
}

struct MedicalProfile: Codable, Equatable, Hashable {
    var name: String = ""
    var dob: String = ""
    var blood: String = ""
    var donor: Bool = false
    var allergies: [String] = []
    var meds: [String] = []
    var conditions: [String] = []
    var contacts: [EmergencyContact] = []
    var updated: String = ""

    /// Count of edits made to this profile since pairing (the initial
    /// first-time-setup save does not count). Drives the edit auth grace
    /// period — see `hasOwnerData` and `EditProfileView.requiresEditAuth`.
    var editCount: Int = 0

    /// True once the owner has saved any medical ID on this device. Drives
    /// edit auth — first-time setup stays open until Save.
    var hasOwnerData: Bool {
        if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return true }
        if !dob.isEmpty || !blood.isEmpty { return true }
        if !allergies.isEmpty || !meds.isEmpty || !conditions.isEmpty { return true }
        if contacts.contains(where: {
            !$0.name.trimmingCharacters(in: .whitespaces).isEmpty
                || !$0.phone.trimmingCharacters(in: .whitespaces).isEmpty
                || !$0.rel.trimmingCharacters(in: .whitespaces).isEmpty
        }) { return true }
        return false
    }

    enum CodingKeys: String, CodingKey {
        case name, dob, blood, donor, allergies, meds, conditions, contacts, updated, editCount
    }
}

extension MedicalProfile {
    /// Custom decode so profiles saved before `editCount` existed still load —
    /// synthesized Codable would otherwise throw `keyNotFound` on that field
    /// and silently reset the owner's saved profile to empty (see ProfileStore.init).
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        dob = try c.decode(String.self, forKey: .dob)
        blood = try c.decode(String.self, forKey: .blood)
        donor = try c.decode(Bool.self, forKey: .donor)
        allergies = try c.decode([String].self, forKey: .allergies)
        meds = try c.decode([String].self, forKey: .meds)
        conditions = try c.decode([String].self, forKey: .conditions)
        contacts = try c.decode([EmergencyContact].self, forKey: .contacts)
        updated = try c.decode(String.self, forKey: .updated)
        editCount = try c.decodeIfPresent(Int.self, forKey: .editCount) ?? 0
    }
}
