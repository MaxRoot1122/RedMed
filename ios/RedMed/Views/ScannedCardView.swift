import SwiftUI
import UIKit

/// First-responder emergency card — shown when a bracelet is scanned in-app
/// (NFC session or legacy `redmed://` / HTTPS `#d=` deep link). Displays THAT
/// tag's decoded profile, never the device owner's `ProfileStore`. Read-only:
/// a responder must not be able to overwrite the owner's My ID from here.
struct ScannedCardView: View {
    @Environment(\.layoutMetrics) private var layout

    let profile: MedicalProfile
    @Environment(\.dismiss) private var dismiss
    @State private var copiedSummary = false
    @State private var traumaExpanded = false

    private var ageLine: String {
        var parts: [String] = []
        if let age = ageYears(from: profile.dob) {
            parts.append("\(age) yrs")
        }
        if !profile.dob.isEmpty {
            parts.append("DOB \(profile.dob)")
        }
        if !profile.blood.isEmpty {
            parts.append("Blood \(profile.blood)")
        }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    EmergencyHeroHeader(
                        name: profile.name,
                        metaLine: ageLine,
                        donor: profile.donor
                    )

                    VStack(alignment: .leading, spacing: layout.s(18)) {
                        Call911Button()

                        if !profile.allergies.isEmpty {
                            BulletListBlock(title: "Allergies", items: profile.allergies, critical: true)
                        }
                        if !profile.meds.isEmpty {
                            BulletListBlock(title: "Medications", items: profile.meds)
                        }
                        if !profile.conditions.isEmpty {
                            BulletListBlock(title: "Medical conditions", items: profile.conditions)
                        }

                        let contacts = profile.contacts.filter { !$0.name.isEmpty || !$0.phone.isEmpty }
                        if !contacts.isEmpty {
                            contactsBlock(contacts)
                        }

                        Button {
                            UIPasteboard.general.string = EmergencySummaryBuilder.build(profile: profile)
                            copiedSummary = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                copiedSummary = false
                            }
                        } label: {
                            Text(copiedSummary ? "Copied!" : "Copy medical summary")
                        }
                        .buttonStyle(InkButtonStyle())

                        DisclosureGroup(isExpanded: $traumaExpanded) {
                            TraumaHospitalsSection()
                        } label: {
                            Text("Trauma center transport")
                                .font(layout.subheadlineFont(weight: .bold))
                                .foregroundStyle(AppTheme.ink)
                        }

                        ThemeNoteText(text: "Tap the band → this card. Nothing saved to this phone.")

                        if profile.allergies.isEmpty,
                           profile.meds.isEmpty,
                           profile.conditions.isEmpty,
                           contacts.isEmpty {
                            ThemeNoteText(text: "No allergies, meds, conditions, or contacts were written to this band.")
                        }
                    }
                    .padding(layout.screenPad)
                    .padding(.bottom, layout.s(28))
                }
                .reactiveScrollTrack()
            }
            .scrollIndicators(.visible, axes: .vertical)
            .background(AppTheme.pageBg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("EMERGENCY CARD")
                        .font(layout.captionFont(weight: .heavy))
                        .tracking(1.2)
                        .foregroundStyle(AppTheme.muted)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func contactsBlock(_ contacts: [EmergencyContact]) -> some View {
        VStack(alignment: .leading, spacing: layout.s(10)) {
            SectionEyebrow(text: "Emergency contacts", tint: AppTheme.muted)
            VStack(spacing: layout.s(10)) {
                ForEach(contacts) { contact in
                    ContactCardRow(
                        name: contact.name,
                        relation: contact.rel,
                        phone: contact.phone
                    )
                }
            }
        }
    }

    private func ageYears(from dob: String) -> Int? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: dob) else { return nil }
        return Calendar.current.dateComponents([.year], from: date, to: Date()).year
    }
}

#Preview {
    ScannedCardView(profile: MedicalProfile(
        name: "Alex Rivera",
        dob: "1990-04-12",
        blood: "O+",
        donor: true,
        allergies: ["Penicillin"],
        meds: ["Metformin 500mg"],
        conditions: ["Type 2 diabetes"],
        contacts: [EmergencyContact(name: "Sam Rivera", rel: "Spouse", phone: "5551234567")]
    ))
    .withLayoutMetrics()
}
