import SwiftUI
import CoreLocation

/// Offline trauma hospital picker — shared by Find 911 and the NFC emergency card.
struct TraumaHospitalsSection: View {
    @Environment(\.layoutMetrics) private var layout

    /// When set (Find 911), cities and hospitals sort closest-first.
    var gpsCoordinate: CLLocationCoordinate2D?

    @AppStorage("redMedTraumaState") private var traumaState = ""
    @AppStorage("redMedTraumaCity") private var traumaCity = ""

    var body: some View {
        let cities = TraumaHospitalFinder.cities(in: traumaState, from: gpsCoordinate)
        let hospitals = TraumaHospitalFinder.hospitals(
            state: traumaState,
            city: traumaCity,
            from: gpsCoordinate
        )

        VStack(alignment: .leading, spacing: layout.spaceMD) {
            SectionEyebrow(text: "Trauma hospitals", tint: AppTheme.medical)

            Text("For transport when they may not survive if you wait for a closer hospital.")
                .font(layout.footnoteFont(weight: .semibold))
                .foregroundStyle(AppTheme.ink.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)

            Text(gpsCoordinate != nil
                ? "Pick state and city — sorted closest to your GPS."
                : "Pick state and city — verified trauma centers only.")
                .font(layout.captionFont())
                .foregroundStyle(AppTheme.muted)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: layout.spaceSM) {
                traumaPicker(
                    label: "State",
                    placeholder: "Select state",
                    selection: $traumaState,
                    options: TraumaHospitalFinder.states
                )
                .onChange(of: traumaState) { _ in
                    traumaCity = ""
                }

                if !traumaState.isEmpty {
                    traumaPicker(
                        label: "City",
                        placeholder: cities.isEmpty ? "No cities in catalog" : "Select city",
                        selection: $traumaCity,
                        options: cities,
                        disabled: cities.isEmpty
                    )
                }
            }

            if !traumaState.isEmpty && !traumaCity.isEmpty {
                if hospitals.isEmpty {
                    Text("None in this area")
                        .font(layout.captionFont(weight: .semibold))
                        .foregroundStyle(AppTheme.muted)
                } else {
                    VStack(spacing: layout.spaceSM) {
                        ForEach(hospitals) { hospital in
                            hospitalRow(hospital)
                        }
                    }

                    Text("Call 911 first. Tell the dispatcher you need trauma-center transport and your location.")
                        .font(layout.caption2Font())
                        .foregroundStyle(AppTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(layout.spaceLG)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    private func traumaPicker(
        label: String,
        placeholder: String,
        selection: Binding<String>,
        options: [String],
        disabled: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: layout.spaceXS) {
            Text(label.uppercased())
                .font(layout.caption2Font(weight: .bold))
                .tracking(0.6)
                .foregroundStyle(AppTheme.muted)

            HStack(spacing: layout.spaceSM) {
                Picker(label, selection: selection) {
                    Text(placeholder).tag("")
                    ForEach(options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .font(layout.bodyFont(weight: .semibold))
                .foregroundStyle(AppTheme.ink)
                .disabled(disabled)

                Spacer(minLength: 0)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: layout.s(11), weight: .bold))
                    .foregroundStyle(AppTheme.muted)
            }
            .padding(.horizontal, layout.spaceMD)
            .frame(minHeight: layout.s(44))
            .background(Color.white.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: layout.innerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: layout.innerRadius, style: .continuous)
                    .stroke(AppTheme.line, lineWidth: 1)
            )
            .opacity(disabled ? 0.55 : 1)
        }
    }

    private func hospitalRow(_ hospital: TraumaHospital) -> some View {
        HStack(alignment: .top, spacing: layout.spaceMD) {
            VStack(alignment: .leading, spacing: layout.spaceXS) {
                Text(hospital.name)
                    .font(layout.subheadlineFont(weight: .bold))
                    .foregroundStyle(AppTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(hospital.levelLabel) · \(hospital.city), \(hospital.state)")
                    .font(layout.captionFont(weight: .semibold))
                    .foregroundStyle(AppTheme.muted)
                if let coordinate = gpsCoordinate {
                    Text(TraumaHospitalFinder.distanceLabel(from: coordinate, to: hospital))
                        .font(layout.captionFont(weight: .bold))
                        .foregroundStyle(AppTheme.medical)
                }
                if !hospital.phone.isEmpty {
                    Text(hospital.phone)
                        .font(layout.captionFont())
                        .foregroundStyle(AppTheme.muted)
                }
            }
            Spacer(minLength: layout.spaceSM)
            if let url = hospital.mapsURL {
                Link("Maps", destination: url)
                    .font(layout.captionFont(weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, layout.spaceMD)
                    .padding(.vertical, layout.spaceSM)
                    .background(AppTheme.medical)
                    .clipShape(Capsule())
            }
        }
        .padding(layout.spaceMD)
        .appCard(elevated: false)
    }
}
