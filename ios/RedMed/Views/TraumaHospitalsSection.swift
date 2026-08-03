import SwiftUI
import CoreLocation

/// Offline trauma hospital picker — artifact fixed typography.
struct TraumaHospitalsSection: View {
    var gpsCoordinate: CLLocationCoordinate2D?

    @AppStorage("redMedTraumaState") private var traumaState = ""
    @AppStorage("redMedTraumaCounty") private var traumaCounty = ""
    @State private var googleRegionNote: String?

    var body: some View {
        let needsCounty = TraumaHospitalFinder.needsCountyPicker(for: traumaState)
        let hospitals = TraumaHospitalFinder.resolvedHospitals(state: traumaState, county: traumaCounty)

        VStack(alignment: .leading, spacing: 10) {
            Text("TRAUMA HOSPITALS")
                .font(.system(size: 10, weight: .bold))
                .kerning(1)
                .foregroundColor(.redmedAccent)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Capsule().fill(Color.redmedAccent.opacity(0.1)))

            Text("For transport when they may not survive if you wait for a closer hospital.")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.redmedDark)
            Text("Verified trauma centers only — pick your state. County appears only when the list is long (30+).")
                .font(.system(size: 11))
                .foregroundColor(.redmedMuted)
                .lineSpacing(3)

            if let googleRegionNote {
                Text(googleRegionNote)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.redmedAccent)
            }

            Picker("State", selection: $traumaState) {
                Text("Select state").tag("")
                ForEach(TraumaHospitalFinder.states, id: \.self) { state in
                    Text(state).tag(state)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: traumaState) { _ in traumaCounty = "" }

            if needsCounty {
                Picker("County", selection: $traumaCounty) {
                    Text("Select county").tag("")
                    ForEach(TraumaHospitalFinder.counties(in: traumaState), id: \.self) { county in
                        Text(county).tag(county)
                    }
                }
                .pickerStyle(.menu)
            }

            if !traumaState.isEmpty && (!needsCounty || !traumaCounty.isEmpty) {
                if hospitals.isEmpty {
                    Text("None in this area")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.redmedMuted)
                } else {
                    ForEach(hospitals) { hospital in
                        HStack(alignment: .top, spacing: 10) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(hospital.name)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.redmedDark)
                                Text("\(hospital.levelLabel) · \(hospital.city), \(hospital.state)")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.redmedMuted)
                                if !hospital.phone.isEmpty {
                                    Text(hospital.phone)
                                        .font(.system(size: 11))
                                        .foregroundColor(.redmedMuted)
                                }
                            }
                            Spacer(minLength: 8)
                            if let url = hospital.mapsURL {
                                Link(destination: url) {
                                    Text("Maps")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.redmedAccent)
                                        .padding(.horizontal, 12).padding(.vertical, 8)
                                        .background(Color.redmedAccent.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(10)
                        .background(Color.redmedBg)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Text("Call 911 first. Tell the dispatcher you need trauma-center transport and your location.")
                        .font(.system(size: 10))
                        .foregroundColor(.redmedMuted)
                        .lineSpacing(3)
                }
            }
        }
        .task(id: gpsCoordinate.map { "\($0.latitude),\($0.longitude)" }) {
            guard let coordinate = gpsCoordinate else { return }
            guard let region = await GoogleGeocoder.reverseGeocode(coordinate: coordinate) else { return }
            traumaState = region.state
            traumaCounty = TraumaHospitalFinder.matchCounty(state: region.state, name: region.county) ?? ""
            googleRegionNote = "Region from GPS (Google) — offline trauma centers below."
        }
    }
}
