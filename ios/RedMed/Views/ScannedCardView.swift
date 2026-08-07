import SwiftUI
import UIKit

/// First-responder emergency card — artifact styling, fixed sizes, cream background.
struct ScannedCardView: View {
    let profile: MedicalProfile
    @Environment(\.dismiss) private var dismiss
    @State private var copiedSummary = false
    @State private var traumaExpanded = false

    /// High-acuity keywords — match web card `ACUITY_RE` so seizure/shunt
    /// style conditions get critical treatment in-app too.
    private static let acuityPattern = try! NSRegularExpression(
        pattern: #"seizure|epilep|shunt|anaphylax|diabetes|insulin|anticoag|warfarin|eliquis|xarelto|asthma|pacemaker|icd\b|transplant|hemophil|bleeding disorder|adrenal|addison|airway|tracheostom|vp/?sp|tonic.?clonic|status epilepticus"#,
        options: .caseInsensitive
    )

    private var filledContacts: [EmergencyContact] {
        profile.contacts.filter {
            !$0.name.trimmingCharacters(in: .whitespaces).isEmpty
                || !$0.phone.trimmingCharacters(in: .whitespaces).isEmpty
                || !$0.rel.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    private var criticalConditions: [String] {
        profile.conditions.filter { isHighAcuity($0) }
    }

    private var otherConditions: [String] {
        profile.conditions.filter { !isHighAcuity($0) }
    }

    private func isHighAcuity(_ text: String) -> Bool {
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return Self.acuityPattern.firstMatch(in: text, options: [], range: range) != nil
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    heroHeader

                    VStack(alignment: .leading, spacing: 0) {
                        PrimaryButton(title: "Call 911") {
                            if let url = EmergencySummaryBuilder.call911URL {
                                UIApplication.shared.open(url)
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 4)

                        // Clinical order mirrors hosted card/: allergies → critical
                        // conditions → other conditions → meds → contacts.
                        if profile.allergies.isEmpty {
                            nkdaSection
                        } else {
                            cardSection(title: "Allergies", items: profile.allergies, critical: true)
                        }
                        if !criticalConditions.isEmpty {
                            cardSection(title: "Critical conditions", items: criticalConditions, critical: true)
                        }
                        if !otherConditions.isEmpty {
                            cardSection(title: "Conditions", items: otherConditions)
                        }
                        if !profile.meds.isEmpty {
                            cardSection(title: "Medications", items: profile.meds)
                        }
                        if !filledContacts.isEmpty {
                            contactsSection
                        }

                        Button {
                            UIPasteboard.general.string = EmergencySummaryBuilder.build(profile: profile)
                            copiedSummary = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copiedSummary = false }
                        } label: {
                            Text(copiedSummary ? "Copied!" : "Copy medical summary")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.redmedDark)
                                .clipShape(Capsule())
                        }
                        .padding(.top, 8)

                        traumaCard

                        Text("Tap the band → this card. Nothing saved to this phone, nothing sent to a server.")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.redmedMuted)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 12)

                        if profile.allergies.isEmpty,
                           profile.meds.isEmpty,
                           profile.conditions.isEmpty,
                           filledContacts.isEmpty {
                            Text("No allergies, meds, conditions, or contacts were written to this band.")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.redmedMuted)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
                }
            }
            .background(Color.redmedBg)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("EMERGENCY CARD")
                        .font(.system(size: 11, weight: .heavy))
                        .kerning(1.2)
                        .foregroundColor(.redmedMuted)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.redmedAccent)
                }
            }
        }
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("REDMED")
                .font(.system(size: 11, weight: .heavy))
                .kerning(1.8)
                .foregroundColor(.white.opacity(0.88))

            Text(profile.name.isEmpty ? "Medical ID" : profile.name)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

            if !heroChips.isEmpty {
                FlowChips(chips: heroChips)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 28)
        .padding(.bottom, 22)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.957, green: 0.247, blue: 0.369),
                    Color.redmedAccent,
                    Color(red: 0.749, green: 0.071, blue: 0.216)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var heroChips: [HeroChip] {
        var chips: [HeroChip] = []
        if !profile.blood.isEmpty {
            chips.append(HeroChip(text: "Blood \(profile.blood)", emphasized: true))
        }
        if let age = ageYears(from: profile.dob) {
            chips.append(HeroChip(text: "\(age) yrs", emphasized: false))
        }
        if !profile.dob.isEmpty {
            chips.append(HeroChip(text: "DOB \(profile.dob)", emphasized: false))
        }
        if profile.donor {
            chips.append(HeroChip(text: "Organ donor", emphasized: false))
        }
        return chips
    }

    private var nkdaSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "Allergies").padding(.top, 12)
            Text("No known allergies")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(red: 0.086, green: 0.396, blue: 0.204))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16).padding(.vertical, 13)
                .background(Color(red: 0.086, green: 0.396, blue: 0.204).opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.086, green: 0.396, blue: 0.204).opacity(0.16), lineWidth: 1)
                )
        }
    }

    @ViewBuilder
    private func cardSection(title: String, items: [String], critical: Bool = false) -> some View {
        SectionLabel(text: title).padding(.top, 12)
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Text(item)
                    .font(.system(size: 15, weight: critical ? .semibold : .regular))
                    .foregroundColor(critical ? .redmedAccent : .redmedDark)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16).padding(.vertical, 13)
                if index < items.count - 1 {
                    Divider().overlay(Color.black.opacity(0.06))
                }
            }
        }
        .background(critical ? Color.redmedAccent.opacity(0.08) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.redmedDivider, lineWidth: 1))
    }

    private var contactsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "Emergency Contacts").padding(.top, 12)
            VStack(spacing: 0) {
                ForEach(Array(filledContacts.enumerated()), id: \.element.id) { index, contact in
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(contact.name.isEmpty ? "Contact" : contact.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.redmedDark)
                            if !contact.rel.trimmingCharacters(in: .whitespaces).isEmpty {
                                Text(contact.rel)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.redmedMuted)
                            }
                            if !contact.phone.trimmingCharacters(in: .whitespaces).isEmpty {
                                Text(contact.phone)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.redmedMuted)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        if let url = EmergencySummaryBuilder.telURL(phone: contact.phone) {
                            Button("Call") { UIApplication.shared.open(url) }
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.redmedAccent)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 13)
                    if index < filledContacts.count - 1 {
                        Divider().overlay(Color.black.opacity(0.06))
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.redmedDivider, lineWidth: 1))
        }
    }

    private var traumaCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { traumaExpanded.toggle() }
            } label: {
                HStack {
                    Text("Trauma center transport")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.redmedDark)
                    Spacer()
                    Image(systemName: traumaExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.redmedMuted)
                }
            }
            .buttonStyle(.plain)
            .padding(14)

            if traumaExpanded {
                TraumaHospitalsSection()
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
            }
        }
        .background(Color.redmedSurface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.redmedDivider, lineWidth: 1))
        .padding(.top, 12)
    }

    private func ageYears(from dob: String) -> Int? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: dob) else { return nil }
        return Calendar.current.dateComponents([.year], from: date, to: Date()).year
    }
}

private struct HeroChip: Identifiable {
    var id: String { text }
    let text: String
    let emphasized: Bool
}

/// Simple wrapping chip row — avoids importing a layout dependency for a
/// one-off hero meta strip.
private struct FlowChips: View {
    let chips: [HeroChip]

    var body: some View {
        // LazyVGrid keeps chip rows tight on narrow phones without a custom
        // flow layout; two columns is enough for blood/age/DOB/donor.
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 88), spacing: 8)],
            alignment: .leading,
            spacing: 8
        ) {
            ForEach(chips) { chip in
                Text(chip.text)
                    .font(.system(size: chip.emphasized ? 15 : 13, weight: .heavy))
                    .foregroundColor(chip.emphasized ? Color(red: 0.749, green: 0.071, blue: 0.216) : .white)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .background(chip.emphasized ? Color.white : Color.white.opacity(0.16))
                    .overlay(
                        Capsule().stroke(Color.white.opacity(chip.emphasized ? 0 : 0.22), lineWidth: 1)
                    )
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    ScannedCardView(profile: MedicalProfile(
        name: "Maximilian Aguilar-Aasted",
        dob: "2000-06-14",
        blood: "A+",
        donor: false,
        allergies: [],
        meds: ["Lamictal 150 mg", "Depakote 600 mg (3x/day)", "Gabapentin 500 mg (4x/day)"],
        conditions: [
            "Tonic-clonic seizures",
            "GEFS+ type 6",
            "VP/SP shunt",
            "Fused C1–C2",
            "Chronic pain"
        ],
        contacts: [
            EmergencyContact(name: "Mark Aguilar", rel: "Father", phone: "6094393828"),
            EmergencyContact(name: "Kristine Aguilar", rel: "Mother", phone: "6092403035")
        ]
    ))
}
