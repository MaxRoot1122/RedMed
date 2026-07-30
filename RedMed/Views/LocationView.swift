import SwiftUI
import CoreLocation
import UIKit

struct LocationView: View {
    @Environment(\.layoutMetrics) private var layout
    @EnvironmentObject var store: ProfileStore
    @StateObject private var locationManager = LocationManager()
    @StateObject private var networkMonitor = NetworkPathMonitor()
    @State private var copiedCoords = false
    @State private var showSatelliteHelp = false
    @State private var showCallContactPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: layout.spaceMD) {
                    emergencyBlock

                    locationBlock

                    TraumaHospitalsSection(gpsCoordinate: locationManager.coordinate)

                    satelliteDisclosure

                    Text("Coordinates show on this screen only. RedMed has no servers.")
                        .font(layout.caption2Font(weight: .medium))
                        .foregroundStyle(AppTheme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.top, layout.spaceXS)
                        .padding(.bottom, layout.screenBottom)
                }
                .padding(.horizontal, layout.screenPad)
                .padding(.top, layout.spaceXS)
                .reactiveScrollTrack()
            }
            .reactiveScrollChrome()
            .scrollIndicators(.visible, axes: .vertical)
            .screenAtmosphere()
            .navigationTitle("Find 911")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BrandMark(size: .nav)
                }
            }
            .onAppear {
                locationManager.requestLocation()
            }
            .onDisappear { locationManager.stopUpdating() }
            .sheet(isPresented: $showCallContactPicker) {
                EmergencyContactCallSheet(contacts: callableContacts) {
                    showCallContactPicker = false
                }
            }
        }
    }

    private var emergencyBlock: some View {
        VStack(spacing: layout.spaceSM) {
            HStack {
                SectionEyebrow(text: "Emergency", tint: AppTheme.accent)
                Spacer(minLength: 0)
            }

            Text("Call first. Share GPS second.")
                .font(layout.footnoteFont(weight: .medium))
                .foregroundStyle(AppTheme.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            Emergency911ScanPair()

            if networkMonitor.isOffline {
                SoftStatusChip(
                    text: "You're offline. GPS below still works. For satellite emergency, use iPhone Emergency SOS via satellite.",
                    warning: true
                )
            }

            Text("Tap the band — their browser opens the emergency card. RedMed owners can scan here for the native view.")
                .font(layout.caption2Font(weight: .medium))
                .foregroundStyle(AppTheme.muted)
                .multilineTextAlignment(.center)
        }
    }

    private var locationBlock: some View {
        VStack(spacing: layout.spaceSM) {
            Button {
                showCallContactPicker = true
            } label: {
                Text("Call emergency contacts")
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(callableContacts.isEmpty)

            coordinateCard

            if let error = locationManager.errorMessage {
                Text(error)
                    .font(layout.footnoteFont(weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
                    .multilineTextAlignment(.center)
            }

            if locationManager.coordinate != nil {
                Button {
                    guard let c = locationManager.coordinate else { return }
                    UIPasteboard.general.string = LocationFormatting.coordsCopyText(
                        latitude: c.latitude,
                        longitude: c.longitude
                    )
                    copiedCoords = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copiedCoords = false }
                } label: {
                    Text(copiedCoords ? "Copied!" : "Copy coordinates")
                }
                .buttonStyle(InkButtonStyle())

                Text("Read decimal coordinates to the dispatcher first, then accuracy.")
                    .font(layout.caption2Font())
                    .foregroundStyle(AppTheme.muted)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var coordinateCard: some View {
        VStack(spacing: layout.spaceSM) {
            SectionEyebrow(text: "Live GPS", tint: AppTheme.medical)
                .frame(maxWidth: .infinity, alignment: .center)
            if let c = locationManager.coordinate {
                Text(String(format: "%.6f, %.6f", c.latitude, c.longitude))
                    .font(.system(size: layout.s(22), design: .monospaced).weight(.bold))
                    .foregroundStyle(AppTheme.ink)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text(LocationFormatting.dms(latitude: c.latitude, longitude: c.longitude))
                    .font(.system(size: layout.s(14), design: .monospaced).weight(.semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                if let acc = locationManager.accuracy, acc > 0 {
                    Text(accuracyLabel(for: acc))
                        .font(layout.captionFont(weight: .semibold))
                        .foregroundStyle(acc > 100 ? AppTheme.accent : AppTheme.muted)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                HStack(spacing: layout.spaceMD) {
                    if let heading = locationManager.heading {
                        Label(
                            "\(Int(heading))° \(LocationFormatting.cardinal(for: heading))",
                            systemImage: "location.north.line.fill"
                        )
                    }
                    if let altitude = locationManager.altitude {
                        Label(String(format: "%.0f m", altitude), systemImage: "mountain.2.fill")
                    }
                }
                .font(layout.captionFont(weight: .semibold))
                .foregroundStyle(AppTheme.muted)
                .padding(.top, layout.s(2))
                .frame(maxWidth: .infinity, alignment: .center)

                if let timestamp = locationManager.locationTimestamp {
                    Text("As of \(timestamp.formatted(date: .abbreviated, time: .shortened))")
                        .font(layout.caption2Font())
                        .foregroundStyle(AppTheme.muted)
                        .padding(.top, layout.s(2))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            } else if locationManager.errorMessage == nil {
                ProgressView("Getting GPS…")
                    .tint(AppTheme.medical)
                    .foregroundStyle(AppTheme.ink)
                    .padding(.vertical, layout.spaceSM)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Text("GPS unavailable")
                    .font(layout.subheadlineFont(weight: .semibold))
                    .foregroundStyle(AppTheme.muted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, layout.spaceLG)
        .padding(.horizontal, layout.spaceMD)
        .appCard()
    }

    private var satelliteDisclosure: some View {
        VStack(alignment: .leading, spacing: layout.spaceMD) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showSatelliteHelp.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .foregroundStyle(AppTheme.accent)
                    Text("No cell signal?")
                        .font(layout.bodyFont(weight: .semibold))
                        .foregroundStyle(AppTheme.ink)
                    Spacer()
                    Image(systemName: showSatelliteHelp ? "chevron.up" : "chevron.down")
                        .font(layout.captionFont(weight: .bold))
                        .foregroundStyle(AppTheme.muted)
                }
            }
            .buttonStyle(.plain)

            if showSatelliteHelp {
                VStack(alignment: .leading, spacing: layout.spaceSM) {
                    Text("RedMed shows GPS only. Satellite emergency calling is built into your phone — RedMed cannot open or control it.")
                        .font(layout.captionFont())
                        .foregroundStyle(AppTheme.muted)

                    Text("iPhone 14+ (iOS 16.1+): hold Side + Volume until Emergency SOS appears, or Settings → Emergency SOS.")
                        .font(layout.captionFont())
                        .foregroundStyle(AppTheme.muted)

                    Text("Tell the dispatcher street names or landmarks if you can, even with GPS.")
                        .font(layout.captionFont(weight: .medium))
                        .foregroundStyle(AppTheme.ink.opacity(0.75))

                    Call911Button(title: "Open Phone · dial 911", secondary: true)
                }
                .padding(.top, layout.spaceXS)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(layout.spaceMD)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(networkMonitor.isOffline ? AppTheme.accentSoft : AppTheme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: layout.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: layout.cardRadius, style: .continuous)
                .stroke(networkMonitor.isOffline ? AppTheme.accent.opacity(0.28) : AppTheme.line, lineWidth: 1)
        )
    }

    private var callableContacts: [EmergencyContact] {
        store.profile.contacts.filter {
            !EmergencySummaryBuilder.normalizedPhone($0.phone).isEmpty
        }
    }

    private func accuracyLabel(for meters: CLLocationAccuracy) -> String {
        let rounded = Int(meters.rounded())
        if meters > 100 {
            return "Accuracy ±\(rounded) m — poor; tell dispatcher landmarks"
        }
        return "Accuracy ±\(rounded) m"
    }
}

private struct EmergencyContactCallSheet: View {
    @Environment(\.layoutMetrics) private var layout

    let contacts: [EmergencyContact]
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            List(contacts) { contact in
                if let url = EmergencySummaryBuilder.telURL(phone: contact.phone) {
                    Link(destination: url) {
                        HStack(spacing: layout.spaceMD) {
                            VStack(alignment: .leading, spacing: layout.spaceXS) {
                                Text(contact.name.isEmpty ? "Contact" : contact.name)
                                    .font(.system(size: layout.s(17), weight: .semibold))
                                    .foregroundStyle(AppTheme.ink)
                                if !contact.rel.isEmpty {
                                    Text(contact.rel)
                                        .font(layout.subheadlineFont())
                                        .foregroundStyle(AppTheme.muted)
                                }
                            }
                            Spacer(minLength: layout.spaceSM)
                            Image(systemName: "phone.fill")
                                .foregroundStyle(AppTheme.accent)
                        }
                        .padding(.vertical, layout.spaceXS)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Select a contact to call")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
            }
        }
        .presentationDetents(contacts.count <= 3 ? [.medium] : [.large])
    }
}

#Preview {
    LocationView()
        .environmentObject(ProfileStore())
        .withLayoutMetrics()
}
