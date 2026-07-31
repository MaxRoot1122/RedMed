import Foundation

class ProfileManager: ObservableObject {
  @Published var name: String = UserDefaults.standard.string(forKey: "profileName") ?? "Alex Rivera" {
    didSet { UserDefaults.standard.set(name, forKey: "profileName") }
  }
  @Published var dateOfBirth: String = UserDefaults.standard.string(forKey: "profileDOB") ?? "1990-05-14" {
    didSet { UserDefaults.standard.set(dateOfBirth, forKey: "profileDOB") }
  }
  @Published var bloodType: String = UserDefaults.standard.string(forKey: "bloodType") ?? "O negative" {
    didSet { UserDefaults.standard.set(bloodType, forKey: "bloodType") }
  }
  @Published var allergies: [String] = UserDefaults.standard.stringArray(forKey: "allergies") ?? ["Penicillin"] {
    didSet { UserDefaults.standard.set(allergies, forKey: "allergies") }
  }
  @Published var medications: [String] = UserDefaults.standard.stringArray(forKey: "medications") ?? ["Insulin"] {
    didSet { UserDefaults.standard.set(medications, forKey: "medications") }
  }
  @Published var conditions: [String] = UserDefaults.standard.stringArray(forKey: "conditions") ?? ["Type 1 diabetes"] {
    didSet { UserDefaults.standard.set(conditions, forKey: "conditions") }
  }
  @Published var emergencyContacts: [EmergencyContact] = [] {
    didSet { saveContacts() }
  }
  
  init() {
    if let saved = UserDefaults.standard.data(forKey: "emergencyContacts"),
       let decoded = try? JSONDecoder().decode([EmergencyContact].self, from: saved) {
      self.emergencyContacts = decoded
    } else {
      self.emergencyContacts = [EmergencyContact(name: "Jamie Rivera", phone: "555-123-4567", relationship: "Spouse")]
    }
  }
  
  func saveContacts() {
    if let encoded = try? JSONEncoder().encode(emergencyContacts) {
      UserDefaults.standard.set(encoded, forKey: "emergencyContacts")
    }
  }
  
  var profileData: String {
    let contactsJSON = emergencyContacts.map { "\"\($0.name)\": \($0.phone)" }.joined(separator: ", ")
    return """
    {
      "name": "\(name)",
      "dob": "\(dateOfBirth)",
      "blood": "\(bloodType)",
      "donor": true,
      "allergies": \(allergies.map { "\"\($0)\"" }),
      "meds": \(medications.map { "\"\($0)\"" }),
      "conditions": \(conditions.map { "\"\($0)\"" }),
      "contacts": [\(contactsJSON)]
    }
    """
  }
}

struct EmergencyContact: Codable, Identifiable {
  let id = UUID()
  var name: String
  var phone: String
  var relationship: String
  
  enum CodingKeys: String, CodingKey {
    case name, phone, relationship
  }
}
