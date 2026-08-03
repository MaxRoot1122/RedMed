import SwiftUI

private struct EditContactDraft: Identifiable {
    var id = UUID()
    var name = ""
    var detail = ""
}

struct EditProfileView: View {
    @EnvironmentObject var store: ProfileStore
    @EnvironmentObject var link: BraceletLinkStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var birthDate = ""
    @State private var bloodType = ""
    @State private var allergies: [String] = []
    @State private var medications: [String] = []
    @State private var conditions: [String] = []
    @State private var contacts: [EditContactDraft] = []

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") { dismiss() }
                    .font(.system(size: 17))
                    .foregroundColor(.redmedAccent)
                Spacer()
                Text("Edit Profile")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.redmedDark)
                Spacer()
                Button("Save") { Task { await save() } }
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.redmedAccent)
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color(red: 0.949, green: 0.949, blue: 0.969).opacity(0.95))
            .overlay(alignment: .bottom) {
                Divider().overlay(Color.black.opacity(0.12))
            }

            ScrollView(.vertical) {
                formContent
            }
            .background(Color(red: 0.949, green: 0.949, blue: 0.969))
        }
        .onAppear { loadDraft() }
    }

    private var formContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            editSectionLabel("You")
            editCard {
                editRow(label: "Name", text: $name, placeholder: "Full name")
                Divider().padding(.leading, 106)
                editRow(label: "Birth date", text: $birthDate, placeholder: "Month DD, YYYY")
                Divider().padding(.leading, 106)
                editRow(label: "Blood type", text: $bloodType, placeholder: "A+, B−, O+…")
            }

            editSectionLabel("Allergies")
            editCard {
                ForEach($allergies, id: \.self) { $item in
                    listEditRow(text: $item) {
                        withAnimation { allergies.removeAll { $0 == item } }
                    }
                }
                addButton("Add allergy") { allergies.append("") }
            }

            editSectionLabel("Medications")
            editCard {
                ForEach($medications, id: \.self) { $item in
                    listEditRow(text: $item) {
                        withAnimation { medications.removeAll { $0 == item } }
                    }
                }
                addButton("Add medication") { medications.append("") }
            }

            editSectionLabel("Conditions")
            editCard {
                ForEach($conditions, id: \.self) { $item in
                    listEditRow(text: $item) {
                        withAnimation { conditions.removeAll { $0 == item } }
                    }
                }
                addButton("Add condition") { conditions.append("") }
            }

            editSectionLabel("Emergency Contacts")
            editCard {
                ForEach($contacts) { $contact in
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Name", text: $contact.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.redmedDark)
                            TextField("Relationship · phone", text: $contact.detail)
                                .font(.system(size: 13))
                                .foregroundColor(.redmedMuted)
                        }
                        Spacer()
                        Button {
                            withAnimation { contacts.removeAll { $0.id == contact.id } }
                        } label: {
                            Text("✕").font(.system(size: 18)).foregroundColor(.redmedAccent)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 13)
                    Divider().padding(.leading, 16)
                }
                addButton("Add contact") { contacts.append(EditContactDraft()) }
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 16)
        .padding(.bottom, 48)
    }

    @ViewBuilder
    private func listEditRow(text: Binding<String>, onRemove: @escaping () -> Void) -> some View {
        HStack {
            TextField("", text: text)
                .font(.system(size: 15))
                .foregroundColor(.redmedDark)
            Spacer()
            Button(action: onRemove) {
                Text("✕").font(.system(size: 18)).foregroundColor(.redmedAccent)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
        Divider().padding(.leading, 16)
    }

    @ViewBuilder
    private func editSectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(Color(red: 0.42, green: 0.43, blue: 0.48))
            .kerning(0.5)
            .padding(.horizontal, 4)
            .padding(.bottom, 6)
            .padding(.top, text == "You" ? 0 : 22)
    }

    @ViewBuilder
    private func editCard<C: View>(@ViewBuilder content: () -> C) -> some View {
        VStack(spacing: 0) { content() }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func editRow(label: String, text: Binding<String>, placeholder: String) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(red: 0.42, green: 0.43, blue: 0.48))
                .frame(width: 90, alignment: .leading)
                .padding(.trailing, 12)
            TextField(placeholder, text: text)
                .font(.system(size: 15))
                .foregroundColor(.redmedDark)
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
    }

    @ViewBuilder
    private func addButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill").font(.system(size: 18))
                Text(label).font(.system(size: 15))
            }
            .foregroundColor(.redmedAccent)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16).padding(.vertical, 13)
        }
        .buttonStyle(.plain)
    }

    private func loadDraft() {
        let profile = store.profile
        name = profile.name
        bloodType = profile.blood
        allergies = profile.allergies
        medications = profile.meds
        conditions = profile.conditions

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
                detail: [contact.rel, contact.phone]
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                    .joined(separator: " · ")
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
        profile.allergies = allergies.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        profile.meds = medications.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        profile.conditions = conditions.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }

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
            let trimmedDetail = draft.detail.trimmingCharacters(in: .whitespaces)
            guard !trimmedName.isEmpty || !trimmedDetail.isEmpty else { return nil }
            var contact = EmergencyContact(id: draft.id, name: trimmedName, rel: "", phone: "")
            let parts = trimmedDetail.split(separator: "·", maxSplits: 1).map {
                $0.trimmingCharacters(in: .whitespaces)
            }
            if parts.count == 2 {
                contact.rel = parts[0]
                contact.phone = parts[1]
            } else if trimmedDetail.rangeOfCharacter(from: .decimalDigits) != nil {
                contact.phone = trimmedDetail
            } else {
                contact.rel = trimmedDetail
            }
            return contact
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
