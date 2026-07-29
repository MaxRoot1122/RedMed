import SwiftUI

/// Read-only display of the owner's medical profile, shown on the My ID tab.
///
/// Viewing never requires Face ID. Editing opens `EditProfileView`, which
/// prompts biometrics once saved profile data exists on this device.
///
/// Uses `ScrollView` (not `Form`) so long profiles scroll on every iPhone/iPad
/// size. Progress-rail tracking is omitted — its GeometryReader probe fought
/// the scroll gesture on small phones.
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
        ScrollView {
            VStack(alignment: .leading, spacing: layout.spaceLG) {
                header

                summarySection(title: "You") {
                    VStack(spacing: 0) {
                        summaryRow("Name", profile.name)
                        rowDivider
                        summaryRow("Birth date", dobDisplay)
                        rowDivider
                        summaryRow("Blood type", profile.blood.isEmpty ? "Unknown" : profile.blood)
                        rowDivider
                        summaryRow("Organ donor", profile.donor ? "Yes" : "No")
                    }
                }

                summarySection(title: "Allergies") {
                    itemList(profile.allergies)
                }

                summarySection(title: "Medications") {
                    itemList(profile.meds)
                }

                summarySection(title: "Conditions") {
                    itemList(profile.conditions)
                }

                summarySection(title: "Contacts") {
                    if filledContacts.isEmpty {
                        Text("None")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.muted)
                    } else {
                        VStack(alignment: .leading, spacing: layout.spaceMD) {
                            ForEach(filledContacts) { contact in
                                VStack(alignment: .leading, spacing: layout.s(2)) {
                                    Text(contact.name.isEmpty ? "Unnamed contact" : contact.name)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppTheme.ink)
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
                }
            }
            .padding(.horizontal, layout.screenPad)
            .padding(.top, layout.pageTopInset)
            .padding(.bottom, layout.screenBottom)
        }
        .scrollIndicators(.visible, axes: .vertical)
        .screenAtmosphere()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: layout.s(10)) {
            if link.isLinked {
                BrandMark(size: .hero, titleOverride: link.deviceName)
            } else {
                BrandMark(size: .hero, showTagline: true)
                if profile.name.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text("Tap Edit to add your name and set up your bracelet.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, layout.spaceSM)
    }

    @ViewBuilder
    private func summarySection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: layout.spaceSM) {
            Text(title)
                .font(.caption.weight(.bold))
                .tracking(0.8)
                .textCase(.uppercase)
                .foregroundStyle(AppTheme.muted)
            VStack(alignment: .leading, spacing: layout.spaceSM) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(layout.spaceLG)
            .appCard(elevated: false)
        }
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(AppTheme.line)
            .frame(height: 1)
            .padding(.vertical, layout.spaceSM)
    }

    @ViewBuilder
    private func itemList(_ items: [String]) -> some View {
        if items.isEmpty {
            Text("None")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.muted)
        } else {
            VStack(alignment: .leading, spacing: layout.spaceSM) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.muted)
            Spacer(minLength: layout.spaceMD)
            Text(value.isEmpty ? "Not set" : value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, layout.s(2))
    }
}

#Preview {
    NavigationStack {
        ProfileSummaryView(profile: MedicalProfile(), link: BraceletLinkStore())
    }
    .withLayoutMetrics()
}
