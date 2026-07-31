import SwiftUI

/// Read-only display of the owner's medical profile, shown on the My ID tab.
///
/// Viewing never requires Face ID. Editing opens `EditProfileView`, which
/// prompts biometrics once saved profile data exists on this device.
///
/// Uses `Form` (not a custom ScrollView) so scrolling stays reliable under the
/// tab + nav chrome. Progress-rail tracking is intentionally omitted here —
/// its GeometryReader probe was fighting the scroll gesture.
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
                                .font(layout.subheadlineFont(weight: .medium))
                                .foregroundStyle(AppTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.vertical, layout.spaceSM)
                .frame(maxWidth: .infinity, alignment: .leading)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(
                    top: layout.pageTopInset,
                    leading: layout.spaceXS,
                    bottom: layout.spaceSM,
                    trailing: layout.spaceXS
                ))
            }

            if !profile.name.trimmingCharacters(in: .whitespaces).isEmpty {
                Section {
                    criticalInfoCard
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: layout.spaceXS, leading: layout.spaceXS, bottom: layout.spaceSM, trailing: layout.spaceXS))
            }

            Section("You") {
                summaryRow("Name", profile.name)
                summaryRow("Birth date", dobDisplay)
                summaryRow("Blood type", profile.blood.isEmpty ? "Unknown" : profile.blood)
            }

            Section {
                if profile.allergies.isEmpty {
                    Text("None").foregroundStyle(.secondary)
                } else {
                    AllergyChipsRow(allergies: profile.allergies)
                }
            } header: {
                SectionHeaderCount(title: "Allergies", count: profile.allergies.count)
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
                                .font(layout.subheadlineFont(weight: .semibold))
                            let detail = [contact.rel, contact.phone]
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                                .filter { !$0.isEmpty }
                                .joined(separator: " · ")
                            if !detail.isEmpty {
                                Text(detail)
                                    .font(layout.captionFont(weight: .medium))
                                    .foregroundStyle(AppTheme.muted)
                            }
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .scrollIndicators(.visible, axes: .vertical)
        .screenAtmosphere()
    }

    private var criticalInfoCard: some View {
        VStack(alignment: .leading, spacing: layout.spaceSM) {
            Label("Critical Info", systemImage: "staroflife.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppTheme.accent)
                .textCase(.uppercase)
                .tracking(0.5)

            HStack(alignment: .top, spacing: layout.spaceSM) {
                VStack(spacing: 2) {
                    Text(profile.blood.isEmpty ? "—" : profile.blood)
                        .font(.system(size: layout.s(26), weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.accent)
                    Text("Blood Type")
                        .font(.system(size: layout.s(10), weight: .semibold))
                        .foregroundStyle(AppTheme.muted)
                        .textCase(.uppercase)
                        .tracking(0.4)
                }
                .frame(width: layout.s(80))
                .padding(.vertical, layout.spaceSM)
                .background(AppTheme.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: layout.s(12), style: .continuous))

                VStack(alignment: .leading, spacing: layout.s(4)) {
                    Text("Allergies")
                        .font(.system(size: layout.s(10), weight: .semibold))
                        .foregroundStyle(AppTheme.muted)
                        .textCase(.uppercase)
                        .tracking(0.4)
                    if profile.allergies.isEmpty {
                        Text("None recorded")
                            .font(layout.captionFont())
                            .foregroundStyle(AppTheme.muted)
                    } else {
                        ForEach(profile.allergies.prefix(3), id: \.self) { allergy in
                            HStack(spacing: 5) {
                                Circle().fill(AppTheme.accent).frame(width: 5, height: 5)
                                Text(allergy)
                                    .font(.system(size: layout.s(13), weight: .medium))
                                    .foregroundStyle(AppTheme.ink)
                            }
                        }
                        if profile.allergies.count > 3 {
                            Text("+\(profile.allergies.count - 3) more")
                                .font(layout.caption2Font())
                                .foregroundStyle(AppTheme.muted)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(layout.spaceSM)
                .background(AppTheme.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: layout.s(12), style: .continuous))
            }
        }
        .padding(layout.spaceMD)
        .background(
            LinearGradient(
                colors: [AppTheme.accentSoft, AppTheme.accentSoft.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: layout.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: layout.cardRadius, style: .continuous)
                .strokeBorder(AppTheme.accent.opacity(0.18), lineWidth: 1)
        )
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(layout.subheadlineFont(weight: .medium))
                .foregroundStyle(AppTheme.muted)
            Spacer(minLength: layout.spaceMD)
            Text(value.isEmpty ? "Not set" : value)
                .font(layout.subheadlineFont(weight: .semibold))
                .foregroundStyle(AppTheme.ink)
                .multilineTextAlignment(.trailing)
        }
    }
}

/// Wrapping row of allergy capsules — plain HStack/VStack, no GeometryReader,
/// so it can't reintroduce the scroll-fighting bug noted above.
private struct AllergyChipsRow: View {
    @Environment(\.layoutMetrics) private var layout
    let allergies: [String]

    private var rows: [[String]] {
        var result: [[String]] = []
        var current: [String] = []
        var currentWidth: CGFloat = 0
        let maxWidth: CGFloat = 280
        for allergy in allergies {
            let estimatedWidth = CGFloat(allergy.count) * 8 + 40
            if currentWidth + estimatedWidth > maxWidth, !current.isEmpty {
                result.append(current)
                current = []
                currentWidth = 0
            }
            current.append(allergy)
            currentWidth += estimatedWidth
        }
        if !current.isEmpty { result.append(current) }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: layout.spaceXS) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: layout.spaceXS) {
                    ForEach(row, id: \.self) { allergy in
                        Label(allergy, systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: layout.s(13), weight: .semibold))
                            .foregroundStyle(AppTheme.accent)
                            .padding(.horizontal, layout.s(10))
                            .padding(.vertical, layout.s(6))
                            .background(AppTheme.accentSoft)
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(AppTheme.accent.opacity(0.2), lineWidth: 1))
                    }
                }
            }
        }
        .padding(.vertical, layout.spaceXS)
    }
}

private struct SectionHeaderCount: View {
    let title: String
    let count: Int
    var body: some View {
        HStack(spacing: 6) {
            Text(title)
            Spacer()
            Text("\(count)")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppTheme.accent)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(AppTheme.accentSoft)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    NavigationStack {
        ProfileSummaryView(profile: MedicalProfile(), link: BraceletLinkStore())
    }
    .withLayoutMetrics()
}
