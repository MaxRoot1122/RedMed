import SwiftUI

struct SetupView: View {
  @EnvironmentObject var profileManager: ProfileManager
  @State private var showingContactForm = false
  
  var body: some View {
    NavigationStack {
      List {
        Section("Emergency Profile") {
          TextField("Name", text: $profileManager.name)
          TextField("Date of Birth (YYYY-MM-DD)", text: $profileManager.dateOfBirth)
          TextField("Blood Type", text: $profileManager.bloodType)
        }
        
        Section("Allergies") {
          ForEach($profileManager.allergies, id: \.self) { $allergy in
            TextField("Allergy", text: $allergy)
          }
          Button(action: { profileManager.allergies.append("") }) {
            Label("Add Allergy", systemImage: "plus.circle.fill")
          }
        }
        
        Section("Medications") {
          ForEach($profileManager.medications, id: \.self) { $med in
            TextField("Medication", text: $med)
          }
          Button(action: { profileManager.medications.append("") }) {
            Label("Add Medication", systemImage: "plus.circle.fill")
          }
        }
        
        Section("Medical Conditions") {
          ForEach($profileManager.conditions, id: \.self) { $cond in
            TextField("Condition", text: $cond)
          }
          Button(action: { profileManager.conditions.append("") }) {
            Label("Add Condition", systemImage: "plus.circle.fill")
          }
        }
        
        Section("Emergency Contacts") {
          ForEach(profileManager.emergencyContacts) { contact in
            VStack(alignment: .leading, spacing: 4) {
              Text(contact.name)
                .font(.headline)
              Text(contact.phone)
                .font(.caption)
                .foregroundColor(.secondary)
              Text(contact.relationship)
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
          .onDelete { indices in
            profileManager.emergencyContacts.remove(atOffsets: indices)
          }
          Button(action: { showingContactForm = true }) {
            Label("Add Contact", systemImage: "plus.circle.fill")
          }
        }
        
        Section {
          Button(action: {}) {
            Text("Save & Write to Band")
              .frame(maxWidth: .infinity)
              .padding(8)
              .foregroundColor(.white)
              .background(Color.black)
              .cornerRadius(8)
          }
          .listRowInsets(EdgeInsets())
          .listRowSeparator(.hidden)
        }
      }
      .navigationTitle("Emergency Profile")
      .sheet(isPresented: $showingContactForm) {
        AddContactView(profileManager: profileManager)
      }
    }
  }
}

struct AddContactView: View {
  @ObservedObject var profileManager: ProfileManager
  @Environment(\.dismiss) var dismiss
  @State private var name = ""
  @State private var phone = ""
  @State private var relationship = ""
  
  var body: some View {
    NavigationStack {
      List {
        TextField("Name", text: $name)
        TextField("Phone", text: $phone)
        TextField("Relationship", text: $relationship)
      }
      .navigationTitle("Add Contact")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            profileManager.emergencyContacts.append(
              EmergencyContact(name: name, phone: phone, relationship: relationship)
            )
            dismiss()
          }
        }
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
      }
    }
  }
}

#Preview {
  SetupView()
    .environmentObject(ProfileManager())
}
