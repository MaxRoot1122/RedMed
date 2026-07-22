import Foundation

/// Field names intentionally mirror the JSON schema used by the web app's
/// index.html (name, dob, blood, donor, allergies, meds, conditions,
/// contacts, doc, insurance, notes, updated) so a tag written by this app
/// decodes correctly if ever opened by the web version, and vice versa.

struct EmergencyContact: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var name: String = ""
    var rel: String = ""
    var phone: String = ""

    enum CodingKeys: String, CodingKey {
        case name, rel, phone
    }
}

struct DoctorInfo: Codable, Equatable, Hashable {
    var name: String = ""
    var phone: String = ""
}

struct InsuranceInfo: Codable, Equatable, Hashable {
    var provider: String = ""
    var id: String = ""
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
    var doc: DoctorInfo = DoctorInfo()
    var insurance: InsuranceInfo = InsuranceInfo()
    var notes: String = ""
    var updated: String = ""
}
