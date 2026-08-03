import SwiftUI

private struct EditLineDraft: Identifiable {
    let id: UUID
    var text: String

    init(id: UUID = UUID(), text: String = "") {
        self.id = id
        self.text = text
    }
}

private struct EditContactDraft: Identifiable {
    var id = UUID()
    var name = ""
    var rel = ""
    var phone = ""
}

struct EditProfileView: View {
    @EnvironmentObject var store: ProfileStore
    @EnvironmentObject var link: BraceletLinkStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var birthDate = ""
    @State private var bloodType = ""
    @State private var allergies: [EditLineDraft] = []
    @State private var medications: [EditLineDraft] = []
    @State private var conditions: [EditLineDraft] = []
    @State private var contacts: [EditContactDraft] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("You") {
                    clearableField("Full name", text: $name, textContentType: .name, autocapitalization: .words)
                    clearableField("Birth date", text: $birthDate, textContentType: .dateTime, autocapitalization: .words)
                    clearableField(
                        "Blood type",
                        text: $bloodType,
                        autocapitalization: .characters,
                        autocorrectionDisabled: true,
                        keyboardType: .asciiCapable
                    )
                }

                listSection("Allergies", rows: $allergies, placeholder: "Allergy", addLabel: "Add allergy")

                listSection("Medications", rows: $medications, placeholder: "Medication", addLabel: "Add medication")

                listSection("Conditions", rows: $conditions, placeholder: "Condition", addLabel: "Add condition")

                Section("Emergency Contacts") {
                    ForEach($contacts) { $contact in
                        VStack(alignment: .leading, spacing: 8) {
                            clearableField("Name", text: $contact.name, textContentType: .name, autocapitalization: .words)
                            clearableField("Relationship", text: $contact.rel, autocapitalization: .words)
                            clearableField(
                                "Phone",
                                text: $contact.phone,
                                textContentType: .telephoneNumber,
                                keyboardType: .phonePad
                            )
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                contacts.removeAll { $0.id == contact.id }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    Button {
                        contacts.append(EditContactDraft())
                    } label: {
                        Label("Add contact", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { Task { await save() } }
                        .fontWeight(.semibold)
                }
            }
        }
        .withLayoutMetrics()
        .onAppear { loadDraft() }
    }

    private func clearableField(
        _ placeholder: String,
        text: Binding<String>,
        textContentType: UITextContentType? = nil,
        autocapitalization: TextInputAutocapitalization = .sentences,
        autocorrectionDisabled: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        ClearableTextField(
            placeholder: placeholder,
            text: text,
            keyboardType: keyboardType,
            textContentType: textContentType,
            autocapitalization: autocapitalization,
            autocorrectionDisabled: autocorrectionDisabled
        )
    }

    @ViewBuilder
    private func listSection(
        _ title: String,
        rows: Binding<[EditLineDraft]>,
        placeholder: String,
        addLabel: String
    ) -> some View {
        Section(title) {
            ForEach(rows) { $row in
                clearableField(placeholder, text: $row.text, autocapitalization: .sentences)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            rows.wrappedValue.removeAll { $0.id == row.id }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            Button {
                rows.wrappedValue.append(EditLineDraft())
            } label: {
                Label(addLabel, systemImage: "plus.circle.fill")
            }
        }
    }

    private func loadDraft() {
        let profile = store.profile
        name = profile.name
        bloodType = profile.blood
        allergies = profile.allergies.map { EditLineDraft(text: $0) }
        medications = profile.meds.map { EditLineDraft(text: $0) }
        conditions = profile.conditions.map { EditLineDraft(text: $0) }

        if !profile.dob.isEmpty {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            if let date = f.date(from: profile.dob) {
                let display = DateFormatter()
                display.dateStyle = .long
                birthDate = display.string(from: date)
            } else {
                birthDate = profile.dob
            }
        }

        contacts = profile.contacts.map { contact in
            EditContactDraft(
                id: contact.id,
                name: contact.name,
                rel: contact.rel,
                phone: contact.phone
            )
        }
    }

    @MainActor
    private func save() async {
        if store.profile.hasOwnerData && !link.pendingPostPairingGrace {
            let ok = await BiometricGate.authenticate(reason: "Confirm saving your medical ID")
            guard ok else { return }
        }

        var profile = store.profile
        profile.name = name.trimmingCharacters(in: .whitespaces)
        profile.blood = bloodType.trimmingCharacters(in: .whitespaces)
        profile.allergies = allergies
            .map(\.text)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        profile.meds = medications
            .map(\.text)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        profile.conditions = conditions
            .map(\.text)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        if birthDate.trimmingCharacters(in: .whitespaces).isEmpty {
            profile.dob = ""
        } else {
            let display = DateFormatter()
            display.dateStyle = .long
            if let date = display.date(from: birthDate) {
                let iso = DateFormatter()
                iso.dateFormat = "yyyy-MM-dd"
                profile.dob = iso.string(from: date)
            } else {
                profile.dob = birthDate
            }
        }

        profile.contacts = contacts.compactMap { draft in
            let trimmedName = draft.name.trimmingCharacters(in: .whitespaces)
            let trimmedRel = draft.rel.trimmingCharacters(in: .whitespaces)
            let trimmedPhone = draft.phone.trimmingCharacters(in: .whitespaces)
            guard !trimmedName.isEmpty || !trimmedRel.isEmpty || !trimmedPhone.isEmpty else { return nil }
            return EmergencyContact(
                id: draft.id,
                name: trimmedName,
                rel: trimmedRel,
                phone: trimmedPhone
            )
        }

        store.profile = profile
        link.consumePostPairingGrace()
        dismiss()
    }
}

#Preview {
    EditProfileView()
        .environmentObject(ProfileStore())
        .environmentObject(BraceletLinkStore())
}
