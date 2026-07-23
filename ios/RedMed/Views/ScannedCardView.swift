import SwiftUI

/// Shown when the app is opened via a legacy `redmed://` deep link —
/// displays THAT tag's decoded profile, not the device owner's own saved
/// profile in ProfileStore. Read-only: a responder scanning a stranger's
/// tag has no reason to edit it, and shouldn't be able to overwrite it.
struct ScannedCardView: View {
    @Environment(\.layoutMetrics) private var layout

    let profile: MedicalProfile
    @Environment(\.dismiss) private var dismiss

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
                    header

                    VStack(alignment: .leading, spacing: layout.s(18)) {
                        Link(destination: URL(string: "tel:911")!) {
                            Text("Call 911")
                        }
                        .buttonStyle(PrimaryButtonStyle(prominent: true))

                        TraumaHospitalsSection()

                        if !profile.allergies.isEmpty {
                            criticalBlock(title: "Allergies", items: profile.allergies)
                        }
                        if !profile.meds.isEmpty {
                            infoBlock(title: "Medications", items: profile.meds)
                        }
                        if !profile.conditions.isEmpty {
                            infoBlock(title: "Medical conditions", items: profile.conditions)
                        }

                        let contacts = profile.contacts.filter { !$0.name.isEmpty || !$0.phone.isEmpty }
                        if !contacts.isEmpty {
                            contactsBlock(contacts)
                        }

                        if !profile.doc.name.isEmpty || !profile.doc.phone.isEmpty
                            || !profile.insurance.provider.isEmpty || !profile.insurance.id.isEmpty {
                            doctorInsuranceBlock
                        }

                        if !profile.notes.isEmpty {
                            VStack(alignment: .leading, spacing: layout.spaceSM) {
                                SectionEyebrow(text: "Notes", tint: AppTheme.muted)
                                Text(profile.notes)
                                    .font(.body)
                                    .foregroundStyle(AppTheme.ink)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(layout.screenPad)
                    .padding(.bottom, layout.s(28))
                }
            }
            .background(AppTheme.pageBg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("EMERGENCY CARD")
                        .font(.caption.weight(.bold))
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

    private var header: some View {
        VStack(alignment: .leading, spacing: layout.s(10)) {
            Text("REDMED")
                .font(.caption.weight(.bold))
                .tracking(1.6)
                .foregroundStyle(.white.opacity(0.85))

            Text(profile.name.isEmpty ? "Medical ID" : profile.name)
                .font(layout.emergencyNameFont())
                .tracking(-0.5)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            if !ageLine.isEmpty {
                Text(ageLine)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
            }

            if profile.donor {
                Text("Organ donor")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, layout.s(10))
                    .padding(.vertical, layout.s(5))
                    .background(Color.white.opacity(0.18))
                    .clipShape(Capsule())
                    .foregroundStyle(.white)
                    .padding(.top, layout.spaceXS)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, layout.screenPad)
        .padding(.top, layout.s(28))
        .padding(.bottom, layout.screenBottomLarge)
        .background(
            LinearGradient(
                colors: [AppTheme.accent, Color(red: 0.75, green: 0.07, blue: 0.24)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private func criticalBlock(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: layout.s(10)) {
            SectionEyebrow(text: title, tint: AppTheme.accent)
            VStack(alignment: .leading, spacing: layout.spaceSM) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: layout.s(10)) {
                        Circle()
                            .fill(AppTheme.accent)
                            .frame(width: layout.bulletDot, height: layout.bulletDot)
                            .padding(.top, layout.s(7))
                        Text(item)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(AppTheme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(layout.s(14))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.accentSoft)
            .clipShape(RoundedRectangle(cornerRadius: layout.innerRadius, style: .continuous))
        }
    }

    private func infoBlock(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: layout.s(10)) {
            SectionEyebrow(text: title, tint: AppTheme.muted)
            VStack(alignment: .leading, spacing: layout.spaceSM) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: layout.s(10)) {
                        Circle()
                            .fill(AppTheme.medical)
                            .frame(width: layout.bulletDot, height: layout.bulletDot)
                            .padding(.top, layout.s(7))
                        Text(item)
                            .font(.body.weight(.medium))
                            .foregroundStyle(AppTheme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private func contactsBlock(_ contacts: [EmergencyContact]) -> some View {
        VStack(alignment: .leading, spacing: layout.s(10)) {
            SectionEyebrow(text: "Emergency contacts", tint: AppTheme.muted)
            VStack(spacing: layout.s(10)) {
                ForEach(contacts) { contact in
                    HStack(spacing: layout.spaceMD) {
                        VStack(alignment: .leading, spacing: layout.s(2)) {
                            Text(contact.name.isEmpty ? "Contact" : contact.name)
                                .font(.body.weight(.bold))
                                .foregroundStyle(AppTheme.ink)
                            if !contact.rel.isEmpty {
                                Text(contact.rel)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.muted)
                            }
                            if !contact.phone.isEmpty {
                                Text(contact.phone)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(AppTheme.muted)
                            }
                        }
                        Spacer(minLength: layout.spaceSM)
                        if !contact.phone.isEmpty,
                           let url = URL(string: "tel:\(contact.phone.filter { $0.isNumber || $0 == "+" })") {
                            Link(destination: url) {
                                Text("Call")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, layout.spaceLG)
                                    .padding(.vertical, layout.s(10))
                                    .background(AppTheme.medical)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(layout.s(14))
                    .appCard(elevated: false)
                }
            }
        }
    }

    private var doctorInsuranceBlock: some View {
        VStack(alignment: .leading, spacing: layout.s(10)) {
            SectionEyebrow(text: "Doctor & insurance", tint: AppTheme.muted)
            VStack(alignment: .leading, spacing: layout.s(10)) {
                if !profile.doc.name.isEmpty || !profile.doc.phone.isEmpty {
                    HStack(spacing: layout.spaceMD) {
                        VStack(alignment: .leading, spacing: layout.s(2)) {
                            Text(profile.doc.name.isEmpty ? "Doctor" : profile.doc.name)
                                .font(.body.weight(.bold))
                                .foregroundStyle(AppTheme.ink)
                            if !profile.doc.phone.isEmpty {
                                Text(profile.doc.phone)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(AppTheme.muted)
                            }
                        }
                        Spacer(minLength: layout.spaceSM)
                        if !profile.doc.phone.isEmpty,
                           let url = URL(string: "tel:\(profile.doc.phone.filter { $0.isNumber || $0 == "+" })") {
                            Link(destination: url) {
                                Text("Call")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, layout.spaceLG)
                                    .padding(.vertical, layout.s(10))
                                    .background(AppTheme.medical)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                if !profile.insurance.provider.isEmpty || !profile.insurance.id.isEmpty {
                    VStack(alignment: .leading, spacing: layout.s(2)) {
                        Text(profile.insurance.provider.isEmpty ? "Insurance" : profile.insurance.provider)
                            .font(.body.weight(.bold))
                            .foregroundStyle(AppTheme.ink)
                        if !profile.insurance.id.isEmpty {
                            Text("ID \(profile.insurance.id)")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppTheme.muted)
                        }
                    }
                }
            }
            .padding(layout.s(14))
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCard(elevated: false)
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
    ScannedCardView(profile: MedicalProfile())
        .withLayoutMetrics()
}
