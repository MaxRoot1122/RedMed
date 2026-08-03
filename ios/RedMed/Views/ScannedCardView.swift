import SwiftUI
import UIKit

/// First-responder emergency card — artifact styling, fixed sizes, cream background.
struct ScannedCardView: View {
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

    private var filledContacts: [EmergencyContact] {
        profile.contacts.filter {
            !$0.name.trimmingCharacters(in: .whitespaces).isEmpty
                || !$0.phone.trimmingCharacters(in: .whitespaces).isEmpty
                || !$0.rel.trimmingCharacters(in: .whitespaces).isEmpty
        }
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

                        if !profile.allergies.isEmpty {
                            cardSection(title: "Allergies", items: profile.allergies, critical: true)
                        }
                        if !profile.meds.isEmpty {
                            cardSection(title: "Medications", items: profile.meds)
                        }
                        if !profile.conditions.isEmpty {
                            cardSection(title: "Conditions", items: profile.conditions)
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

                        Text("Tap the band → this card. Nothing saved to this phone.")
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
        VStack(alignment: .leading, spacing: 10) {
            Text("REDMED")
                .font(.system(size: 11, weight: .heavy))
                .kerning(1.6)
                .foregroundColor(.white.opacity(0.85))

            Text(profile.name.isEmpty ? "Medical ID" : profile.name)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

            if !ageLine.isEmpty {
                Text(ageLine)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
            }

            if profile.donor {
                Text("Organ donor")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.white.opacity(0.18))
                    .clipShape(Capsule())
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 28)
        .padding(.bottom, 22)
        .background(
            LinearGradient(
                colors: [Color.redmedAccent, Color(red: 0.749, green: 0.071, blue: 0.216)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
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
                    VStack(alignment: .leading, spacing: 2) {
                        Text(contact.name.isEmpty ? "Contact" : contact.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.redmedDark)
                        let detail = [contact.rel, contact.phone]
                            .map { $0.trimmingCharacters(in: .whitespaces) }
                            .filter { !$0.isEmpty }
                            .joined(separator: " · ")
                        if !detail.isEmpty {
                            Text(detail)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.redmedMuted)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
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
}
