import SwiftUI
import CoreLocation
import UIKit

struct LocationView: View {
    @EnvironmentObject var store: ProfileStore
    @StateObject private var locationManager = LocationManager()
    @StateObject private var networkMonitor = NetworkPathMonitor()
    @State private var copiedCoords = false
    @State private var showSatelliteHelp = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header

                    if networkMonitor.isOffline {
                        SoftStatusChip(
                            text: "You're offline. GPS below still works. For satellite emergency, use iPhone Emergency SOS via satellite.",
                            warning: true
                        )
                    }

                    Link(destination: URL(string: "tel:911")!) {
                        Text("Call 911")
                    }
                    .buttonStyle(PrimaryButtonStyle(prominent: true))

                    Button {
                        openEmergencyContactAlert()
                    } label: {
                        Text("Text emergency contacts")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(emergencyPhones.isEmpty)

                    Text("Opens Messages with your saved contacts and location — you tap send.")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.muted)
                        .multilineTextAlignment(.center)

                    Text("Look for a piece of mail.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.ink)
                        .multilineTextAlignment(.center)

                    Text("Tap when you have cell service. Satellite SOS is built into iOS — RedMed cannot start it.")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.muted)
                        .multilineTextAlignment(.center)

                    coordinateCard

                    if let error = locationManager.errorMessage {
                        Text(error)
                            .font(.footnote.weight(.semibold))
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
                            .font(.caption)
                            .foregroundStyle(AppTheme.muted)
                            .multilineTextAlignment(.center)
                    }

                    TraumaHospitalsSection(gpsCoordinate: locationManager.coordinate)

                    satelliteDisclosure

                    Text("Coordinates show on this screen only. RedMed has no servers.")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(AppTheme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                        .padding(.bottom, 28)
                }
                .padding(.horizontal, AppTheme.screenPad)
            }
            .screenAtmosphere()
            .navigationTitle("911")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    BrandMark(size: .nav)
                }
            }
            .onAppear { locationManager.requestLocation() }
            .onDisappear { locationManager.stopUpdating() }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Find 911")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .tracking(-0.4)
                .foregroundStyle(AppTheme.ink)
            Text("Call first. Share GPS second.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    private var coordinateCard: some View {
        VStack(spacing: 8) {
            SectionEyebrow(text: "Live GPS", tint: AppTheme.medical)
            if let c = locationManager.coordinate {
                Text(String(format: "%.6f, %.6f", c.latitude, c.longitude))
                    .font(.system(.title2, design: .monospaced).weight(.bold))
                    .foregroundStyle(AppTheme.ink)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                Text(LocationFormatting.dms(latitude: c.latitude, longitude: c.longitude))
                    .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.85))
                if let acc = locationManager.accuracy, acc > 0 {
                    Text(accuracyLabel(for: acc))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(acc > 100 ? AppTheme.accent : AppTheme.muted)
                }
                HStack(spacing: 12) {
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
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.muted)
                .padding(.top, 2)

                if let timestamp = locationManager.locationTimestamp {
                    Text("As of \(timestamp.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.muted)
                        .padding(.top, 2)
                }
            } else if locationManager.errorMessage == nil {
                ProgressView("Getting GPS…")
                    .tint(AppTheme.medical)
                    .foregroundStyle(AppTheme.ink)
                    .padding(.vertical, 8)
            } else {
                Text("GPS unavailable")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.muted)
            }
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .appCard()
    }

    private var satelliteDisclosure: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showSatelliteHelp.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .foregroundStyle(AppTheme.accent)
                    Text("No cell signal?")
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                    Spacer()
                    Image(systemName: showSatelliteHelp ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.muted)
                }
            }
            .buttonStyle(.plain)

            if showSatelliteHelp {
                VStack(alignment: .leading, spacing: 10) {
                    Text("RedMed shows GPS only. Satellite emergency calling is built into your phone — RedMed cannot open or control it.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.muted)

                    Text("iPhone 14+ (iOS 16.1+): hold Side + Volume until Emergency SOS appears, or Settings → Emergency SOS. Guide: https://support.apple.com/en-us/102669")
                        .font(.caption)
                        .foregroundStyle(AppTheme.muted)

                    Text("Tell the dispatcher street names or landmarks if you can, even with GPS.")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.ink.opacity(0.75))

                    Link(destination: URL(string: "tel:911")!) {
                        Text("Open Phone · dial 911")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(networkMonitor.isOffline ? AppTheme.accentSoft : AppTheme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .stroke(networkMonitor.isOffline ? AppTheme.accent.opacity(0.28) : AppTheme.line, lineWidth: 1)
        )
    }

    private var emergencyPhones: [String] {
        EmergencySummaryBuilder.emergencyContactPhones(in: store.profile)
    }

    private func openEmergencyContactAlert() {
        let phones = emergencyPhones
        guard !phones.isEmpty else { return }
        let body = EmergencySummaryBuilder.contactAlertMessage(
            profile: store.profile,
            coordinate: locationManager.coordinate
        )
        guard let url = EmergencySummaryBuilder.smsURL(phones: phones, body: body) else { return }
        UIApplication.shared.open(url)
    }

    private func accuracyLabel(for meters: CLLocationAccuracy) -> String {
        let rounded = Int(meters.rounded())
        if meters > 100 {
            return "Accuracy ±\(rounded) m — poor; tell dispatcher landmarks"
        }
        return "Accuracy ±\(rounded) m"
    }
}

#Preview {
    LocationView()
        .environmentObject(ProfileStore())
}
