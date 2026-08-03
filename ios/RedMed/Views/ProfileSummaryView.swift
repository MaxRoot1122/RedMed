import SwiftUI

/// Read-only My ID tab — matches artifact `MyIDView.swift` card layout.
struct ProfileSummaryView: View {
    @Environment(\.layoutMetrics) private var layout

    let profile: MedicalProfile
    @ObservedObject var link: BraceletLinkStore
    var onOpenBracelet: () -> Void = {}
    var onOpenHowItWorks: () -> Void = {}
    var onOpenNFC: () -> Void = {}

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

    private var profileIsEmpty: Bool {
        profile.name.trimmingCharacters(in: .whitespaces).isEmpty
            && profile.dob.isEmpty
            && profile.blood.isEmpty
            && profile.allergies.isEmpty
            && profile.meds.isEmpty
            && profile.conditions.isEmpty
            && filledContacts.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: layout.spaceMD) {
                headerBlock

                ProfileSectionHeader(title: "You")
                profileCard {
                    ProfileFieldRow(label: "Name", value: profile.name)
                    ProfileCardDivider()
                    ProfileFieldRow(label: "Birth date", value: dobDisplay)
                    ProfileCardDivider()
                    ProfileFieldRow(label: "Blood type", value: profile.blood)
                }

                listSection(title: "Allergies", items: profile.allergies)
                listSection(title: "Medications", items: profile.meds)
                listSection(title: "Conditions", items: profile.conditions)

                ProfileSectionHeader(title: "Contacts")
                profileCard {
                    if filledContacts.isEmpty {
                        emptyCardRow
                    } else {
                        ForEach(Array(filledContacts.enumerated()), id: \.element.id) { index, contact in
                            if index > 0 { ProfileCardDivider() }
                            VStack(alignment: .leading, spacing: layout.s(2)) {
                                Text(contact.name.isEmpty ? "Unnamed contact" : contact.name)
                                    .font(layout.subheadlineFont(weight: .semibold))
                                    .foregroundStyle(AppTheme.ink)
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, layout.spaceLG)
                            .padding(.vertical, layout.s(11))
                        }
                    }
                }

                quickActions
                artifactFooter
            }
            .padding(.horizontal, layout.screenPad)
            .padding(.bottom, layout.screenBottomLarge)
            .reactiveScrollTrack()
        }
        .reactiveScrollChrome()
        .scrollIndicators(.visible, axes: .vertical)
        .screenAtmosphere()
    }

    @ViewBuilder
    private var headerBlock: some View {
        if profileIsEmpty {
            emptyPrompt
                .padding(.top, layout.spaceSM)
                .padding(.bottom, layout.spaceXS)
        } else if link.isLinked {
            Button(action: onOpenNFC) {
                HStack(spacing: layout.spaceMD) {
                    Image("BrandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: layout.s(48), height: layout.s(48))
                        .clipShape(RoundedRectangle(cornerRadius: layout.s(13), style: .continuous))
                        .shadow(color: AppTheme.accent.opacity(0.15), radius: layout.s(5), y: layout.s(3))
                    VStack(alignment: .leading, spacing: layout.s(3)) {
                        Text(link.deviceName)
                            .font(layout.heroTitleFont())
                            .foregroundStyle(AppTheme.ink)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                        Text("LINKED BRACELET ›")
                            .font(.caption2.weight(.bold))
                            .tracking(0.7)
                            .foregroundStyle(AppTheme.accent.opacity(0.85))
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.top, layout.spaceSM)
            .padding(.bottom, layout.spaceXS)
        }
    }

    private var emptyPrompt: some View {
        HStack(spacing: 0) {
            Text("Tap ")
                .foregroundStyle(AppTheme.muted)
            Text("Edit")
                .bold()
                .foregroundStyle(AppTheme.accent)
            Text(" to add your name and set up your bracelet.")
                .foregroundStyle(AppTheme.muted)
        }
        .font(layout.subheadlineFont(weight: .medium))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var quickActions: some View {
        HStack(spacing: 0) {
            Button(action: onOpenBracelet) {
                HStack(spacing: layout.s(6)) {
                    Image(systemName: "wave.3.right.circle")
                        .font(.system(size: layout.s(18)))
                        .foregroundStyle(AppTheme.accent)
                    Text("Bracelet")
                        .font(layout.captionFont(weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                }
                .padding(.horizontal, layout.s(10))
                .padding(.vertical, layout.s(6))
            }
            .buttonStyle(.plain)
            Divider().frame(height: layout.s(28))
            Button(action: onOpenHowItWorks) {
                HStack(spacing: layout.s(6)) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: layout.s(18)))
                        .foregroundStyle(AppTheme.muted)
                    Text("How it works")
                        .font(layout.captionFont(weight: .semibold))
                        .foregroundStyle(AppTheme.muted)
                }
                .padding(.horizontal, layout.s(10))
                .padding(.vertical, layout.s(6))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, layout.spaceMD)
    }

    private var artifactFooter: some View {
        Text("\"Control your fear. Control the moment. You have what it takes to save a life.\"")
            .font(layout.captionFont())
            .italic()
            .foregroundStyle(AppTheme.ink)
            .multilineTextAlignment(.center)
            .lineSpacing(layout.s(4))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, layout.spaceLG)
            .padding(.top, layout.spaceLG)
            .padding(.bottom, layout.spaceSM)
    }

    @ViewBuilder
    private func profileCard<C: View>(@ViewBuilder content: () -> C) -> some View {
        VStack(spacing: 0) { content() }
            .appCard(elevated: false)
    }

    @ViewBuilder
    private func listSection(title: String, items: [String]) -> some View {
        ProfileSectionHeader(title: title)
        profileCard {
            if items.isEmpty {
                emptyCardRow
            } else {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    if index > 0 { ProfileCardDivider() }
                    Text(item)
                        .font(layout.subheadlineFont())
                        .foregroundStyle(AppTheme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, layout.spaceLG)
                        .padding(.vertical, layout.s(11))
                }
            }
        }
    }

    private var emptyCardRow: some View {
        Text("—")
            .font(layout.subheadlineFont())
            .foregroundStyle(AppTheme.muted.opacity(0.45))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, layout.spaceLG)
            .padding(.vertical, layout.s(11))
    }
}

#Preview {
    ProfileSummaryView(profile: MedicalProfile(), link: BraceletLinkStore())
        .withLayoutMetrics()
}
