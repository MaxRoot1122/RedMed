import SwiftUI

/// Read-only display of the owner's medical profile, shown on the My ID tab.
///
/// This view never edits anything — it exists so the profile can be *viewed*
/// without going through the Face ID gate. Editing only happens through
/// MyIDView's "Edit" button, which presents `EditProfileView(embedded: false)`
/// as a sheet after the biometric check (once armed).
struct ProfileSummaryView: View {
    @Environment(\.layoutMetrics) private var layout

    let profile: MedicalProfile
    @ObservedObject var link: BraceletLinkStore

    private static let dobFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        return f
    }()

    private var dobDisplay: String {
        guard !profile.dob.isEmpty, let date = Self.dobFormatter.date(from: profile.dob) else {
            return "Not set"
        }
        return Self.displayFormatter.string(from: date)
    }

    private var filledContacts: [EmergencyContact] {
        profile.contacts.filter {
            !$0.name.trimmingCharacters(in: .whitespaces).isEmpty
                || !$0.phone.trimmingCharacters(in: .whitespaces).isEmpty
                || !$0.rel.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: layout.s(10)) {
                    if link.isLinked {
                        BrandMark(size: .hero, titleOverride: link.deviceName)
                    } else {
                        BrandMark(size: .hero, showTagline: true)
                        if profile.name.trimmingCharacters(in: .whitespaces).isEmpty {
                            Text("Tap Edit to add your name and set up your bracelet.")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppTheme.muted)
                        }
                    }
                }
                .padding(.vertical, layout.spaceSM)
                .frame(maxWidth: .infinity, alignment: .leading)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(
                    top: layout.spaceXS,
                    leading: layout.spaceXS,
                    bottom: layout.spaceSM,
                    trailing: layout.spaceXS
                ))
            }

            Section("You") {
                summaryRow("Name", profile.name)
                summaryRow("Birth date", dobDisplay)
                summaryRow("Blood type", profile.blood.isEmpty ? "Unknown" : profile.blood)
            }

            Section("Allergies") {
                if profile.allergies.isEmpty {
                    Text("None").foregroundStyle(.secondary)
                } else {
                    ForEach(profile.allergies, id: \.self) { Text($0) }
                }
            }

            Section("Medications") {
                if profile.meds.isEmpty {
                    Text("None").foregroundStyle(.secondary)
                } else {
                    ForEach(profile.meds, id: \.self) { Text($0) }
                }
            }

            Section("Conditions") {
                if profile.conditions.isEmpty {
                    Text("None").foregroundStyle(.secondary)
                } else {
                    ForEach(profile.conditions, id: \.self) { Text($0) }
                }
            }

            Section("Contacts") {
                if filledContacts.isEmpty {
                    Text("None").foregroundStyle(.secondary)
                } else {
                    ForEach(filledContacts) { contact in
                        VStack(alignment: .leading, spacing: layout.s(2)) {
                            Text(contact.name.isEmpty ? "Unnamed contact" : contact.name)
                                .font(.subheadline.weight(.semibold))
                            let detail = [contact.rel, contact.phone]
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                                .filter { !$0.isEmpty }
                                .joined(separator: " · ")
                            if !detail.isEmpty {
                                Text(detail)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(AppTheme.muted)
                            }
                        }
                    }
                }
            }

            Section("Doctor & insurance") {
                summaryRow("Doctor name", profile.doc.name)
                summaryRow("Doctor phone", profile.doc.phone)
                summaryRow("Insurance provider", profile.insurance.provider)
                summaryRow("Member / policy ID", profile.insurance.id)
            }

            if !profile.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Section("Notes") {
                    Text(profile.notes)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .screenAtmosphere()
    }

    @ViewBuilder
    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(AppTheme.muted)
            Spacer()
            Text(value.isEmpty ? "Not set" : value)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileSummaryView(profile: MedicalProfile(), link: BraceletLinkStore())
    }
    .withLayoutMetrics()
}
