import SwiftUI

/// Read-only My ID body — card groups from the Claude artifact design session.
struct ProfileSummaryView: View {
    @Environment(\.layoutMetrics) private var layout

    let profile: MedicalProfile
    @ObservedObject var link: BraceletLinkStore
    var onBraceletTap: (() -> Void)?
    var onHelpTap: (() -> Void)?

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

    private var hasProfileData: Bool {
        !profile.name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var dobDisplay: String {
        guard !profile.dob.isEmpty, let date = Self.dobFormatter.date(from: profile.dob) else {
            return ""
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
            VStack(alignment: .leading, spacing: 0) {
                header

                DesignSectionLabel(text: "You")
                    .padding(.horizontal, layout.screenPad)
                    .padding(.top, layout.s(2))
                DesignCardGroup {
                    profileRow("Name", profile.name)
                    DesignCardDivider()
                    profileRow("Birth date", dobDisplay)
                    DesignCardDivider()
                    profileRow("Blood type", profile.blood.isEmpty ? "" : profile.blood)
                    if profile.donor {
                        DesignCardDivider()
                        profileRow("Organ donor", "Yes")
                    }
                }

                listSection(title: "Allergies", items: profile.allergies)
                listSection(title: "Medications", items: profile.meds)
                listSection(title: "Conditions", items: profile.conditions)

                DesignSectionLabel(text: "Contacts")
                    .padding(.horizontal, layout.screenPad)
                    .padding(.top, layout.spaceMD)
                DesignCardGroup {
                    if filledContacts.isEmpty {
                        emptyRow()
                    } else {
                        ForEach(Array(filledContacts.enumerated()), id: \.element.id) { index, contact in
                            VStack(alignment: .leading, spacing: layout.s(2)) {
                                Text(contact.name.isEmpty ? "Unnamed contact" : contact.name)
                                    .font(.system(size: layout.s(14), weight: .semibold))
                                    .foregroundStyle(AppTheme.ink)
                                let detail = [contact.rel, contact.phone]
                                    .map { $0.trimmingCharacters(in: .whitespaces) }
                                    .filter { !$0.isEmpty }
                                    .joined(separator: " · ")
                                if !detail.isEmpty {
                                    Text(detail)
                                        .font(.system(size: layout.s(12), weight: .medium))
                                        .foregroundStyle(AppTheme.muted)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, layout.screenPad)
                            .padding(.vertical, layout.s(11))
                            if index < filledContacts.count - 1 {
                                DesignCardDivider()
                            }
                        }
                    }
                }

                quickActions
                    .padding(.top, layout.s(14))
                    .padding(.bottom, layout.s(4))

                Text("\"Control your fear. Control the moment. You have what it takes to save a life.\"")
                    .font(.system(size: layout.s(11)))
                    .italic()
                    .foregroundStyle(AppTheme.ink)
                    .multilineTextAlignment(.center)
                    .lineSpacing(layout.s(4))
                    .padding(.horizontal, layout.s(20))
                    .padding(.top, layout.s(20))
                    .padding(.bottom, layout.screenBottom)
                    .frame(maxWidth: .infinity)
            }
        }
        .background(AppTheme.pageBg)
    }

    @ViewBuilder
    private var header: some View {
        if !hasProfileData {
            HStack(spacing: 0) {
                Text("Tap ")
                    .font(.system(size: layout.s(14), weight: .medium))
                    .foregroundStyle(AppTheme.muted)
                Text("Edit")
                    .font(.system(size: layout.s(14), weight: .bold))
                    .foregroundStyle(AppTheme.accent)
                Text(" to add your name and set up your bracelet.")
                    .font(.system(size: layout.s(14), weight: .medium))
                    .foregroundStyle(AppTheme.muted)
            }
            .padding(.horizontal, layout.s(20))
            .padding(.top, layout.s(10))
            .padding(.bottom, layout.s(8))
        } else if link.isLinked {
            Button(action: { onBraceletTap?() }) {
                HStack(spacing: layout.s(10)) {
                    Image("BrandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: layout.s(48), height: layout.s(48))
                        .clipShape(RoundedRectangle(cornerRadius: layout.s(13), style: .continuous))
                        .shadow(color: AppTheme.accent.opacity(0.15), radius: layout.s(5), y: layout.s(3))
                    VStack(alignment: .leading, spacing: layout.s(3)) {
                        Text(link.deviceName.isEmpty ? "\(profile.name)'s iPhone" : link.deviceName)
                            .font(.system(size: layout.s(22), weight: .bold))
                            .foregroundStyle(AppTheme.ink)
                        Text("LINKED BRACELET ›")
                            .font(.system(size: layout.s(10), weight: .bold))
                            .foregroundStyle(AppTheme.accent.opacity(0.85))
                            .kerning(0.7)
                    }
                }
                .padding(.horizontal, layout.s(20))
                .padding(.vertical, layout.s(10))
            }
            .buttonStyle(.plain)
        } else {
            VStack(alignment: .leading, spacing: layout.spaceSM) {
                BrandMark(size: .hero, showTagline: true)
            }
            .padding(.horizontal, layout.s(20))
            .padding(.vertical, layout.s(10))
        }
    }

    @ViewBuilder
    private var quickActions: some View {
        HStack(spacing: 0) {
            Button(action: { onBraceletTap?() }) {
                HStack(spacing: layout.s(6)) {
                    Image(systemName: "wave.3.right.circle")
                        .font(.system(size: layout.s(18)))
                        .foregroundStyle(AppTheme.accent)
                    Text("Bracelet")
                        .font(.system(size: layout.s(12), weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                }
                .padding(.horizontal, layout.s(10))
                .padding(.vertical, layout.s(6))
            }
            .buttonStyle(.plain)

            Divider().frame(height: layout.s(28))

            Button(action: { onHelpTap?() }) {
                HStack(spacing: layout.s(6)) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: layout.s(18)))
                        .foregroundStyle(AppTheme.muted)
                    Text("How it works")
                        .font(.system(size: layout.s(12), weight: .semibold))
                        .foregroundStyle(AppTheme.muted)
                }
                .padding(.horizontal, layout.s(10))
                .padding(.vertical, layout.s(6))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func profileRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: layout.s(14), weight: .medium))
                .foregroundStyle(AppTheme.muted)
            Spacer()
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: layout.s(14), weight: .semibold))
                .foregroundStyle(value.isEmpty ? AppTheme.muted.opacity(0.4) : AppTheme.ink)
        }
        .padding(.horizontal, layout.screenPad)
        .padding(.vertical, layout.s(11))
    }

    @ViewBuilder
    private func emptyRow() -> some View {
        Text("—")
            .font(.system(size: layout.s(14)))
            .foregroundStyle(AppTheme.muted.opacity(0.4))
            .padding(.horizontal, layout.screenPad)
            .padding(.vertical, layout.s(11))
    }

    @ViewBuilder
    private func listSection(title: String, items: [String]) -> some View {
        DesignSectionLabel(text: title)
            .padding(.horizontal, layout.screenPad)
            .padding(.top, layout.spaceMD)
        DesignCardGroup {
            if items.isEmpty {
                emptyRow()
            } else {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    Text(item)
                        .font(.system(size: layout.s(14)))
                        .foregroundStyle(AppTheme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, layout.screenPad)
                        .padding(.vertical, layout.s(11))
                    if index < items.count - 1 {
                        DesignCardDivider()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileSummaryView(profile: MedicalProfile(), link: BraceletLinkStore())
        .withLayoutMetrics()
}
