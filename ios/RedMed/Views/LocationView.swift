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
                VStack(alignment: .leading, spacing: layout.s(8)) {
                    Text("Find 911")
                        .font(.system(size: layout.s(22), weight: .bold))
                        .foregroundStyle(AppTheme.ink)
                    Text("Call first. Share GPS second.")
                        .font(.system(size: layout.s(12), weight: .medium))
                        .foregroundStyle(AppTheme.muted)
                        .padding(.bottom, layout.s(2))

                    if networkMonitor.isOffline {
                        SoftStatusChip(
                            text: "You're offline. GPS below still works. For satellite emergency, use iPhone Emergency SOS via satellite.",
                            warning: true
                        )
                    }

                    HStack(alignment: .top, spacing: layout.spaceMD) {
                        Call911Button(pairLayout: true)
                            .frame(maxWidth: .infinity)
                        ScanEmergencyCardControl(
                            title: "Scan bracelet",
                            pairLayout: true
                        )
                        .frame(maxWidth: .infinity)
                    }

                    Text("Tap the band — their browser opens the emergency card. RedMed owners can scan here for the native view.")
                        .font(.system(size: layout.s(10), weight: .medium))
                        .foregroundStyle(AppTheme.muted)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    Button {
                        showCallContactPicker = true
                    } label: {
                        Text("Call emergency contacts")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(callableContacts.isEmpty)

                    Text("Pick a saved contact to call — iPhone asks before placing the call.")
                        .font(.system(size: layout.s(10), weight: .medium))
                        .foregroundStyle(AppTheme.muted)
                        .multilineTextAlignment(.center)

                    Text("Tap when you have cell service. Satellite SOS is built into iOS — RedMed cannot start it.")
                        .font(.system(size: layout.s(10), weight: .medium))
                        .foregroundStyle(AppTheme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, layout.s(4))

                    coordinateCard
                        .padding(.vertical, layout.s(4))

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
                            .font(.system(size: layout.s(10), weight: .medium))
                            .foregroundStyle(AppTheme.muted)
                            .multilineTextAlignment(.center)
                    }

                    DesignInfoCard(
                        icon: "cross.fill",
                        title: "Roadside First Response",
                        numbered: true,
                        items: [
                            "Turn on hazards. Don't move injured — unless fire or traffic danger.",
                            "Check breathing. Tilt head, lift chin. If no pulse — start CPR.",
                            "Press hard on bleeding. Don't lift to check. Add cloth on top.",
                            "Keep them warm and still. Talk to them. Note time of injury."
                        ]
                    )

                    DesignInfoCard(
                        icon: "info.circle.fill",
                        title: "What to Tell 911",
                        numbered: false,
                        items: [
                            "Your exact location — read the GPS coordinates above.",
                            "Number of people injured and visible injuries.",
                            "If anyone is unconscious or not breathing.",
                            "Stay on the line — let the dispatcher guide you."
                        ]
                    )

                    CommonTraumaGrid()

                    satelliteDisclosure

                    Text("Coordinates show on this screen only. RedMed has no servers.")
                        .font(.system(size: layout.s(10), weight: .medium))
                        .foregroundStyle(AppTheme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.top, layout.s(2))
                        .padding(.bottom, layout.screenBottomLarge)
                }
                .padding(.horizontal, layout.screenPad)
                .padding(.top, layout.s(6))
                .reactiveScrollTrack()
            }
            .scrollIndicators(.visible, axes: .vertical)
            .background(AppTheme.pageBg)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Find 911")
                        .font(.system(size: layout.s(17), weight: .semibold))
                        .foregroundStyle(AppTheme.ink)
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

    private var coordinateCard: some View {
        VStack(spacing: layout.s(6)) {
            Text("LIVE GPS")
                .font(.system(size: layout.s(9), weight: .bold))
                .kerning(1.1)
                .foregroundStyle(AppTheme.accent)
                .padding(.horizontal, layout.s(9))
                .padding(.vertical, layout.s(4))
                .background(Capsule().fill(AppTheme.accentSoft))

            if let c = locationManager.coordinate {
                Text(String(format: "%.6f, %.6f", c.latitude, c.longitude))
                    .font(.system(size: layout.s(17), weight: .bold, design: .monospaced))
                    .foregroundStyle(AppTheme.ink)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)

                if let acc = locationManager.accuracy, acc > 0 {
                    Text(accuracyLabel(for: acc))
                        .font(.system(size: layout.s(11), weight: .semibold))
                        .foregroundStyle(acc > 100 ? AppTheme.accent : AppTheme.muted)
                        .multilineTextAlignment(.center)
                }
            } else if locationManager.errorMessage == nil {
                ProgressView("Getting GPS…")
                    .tint(AppTheme.medical)
                    .foregroundStyle(AppTheme.ink)
                    .padding(.vertical, layout.spaceSM)
            } else {
                Text("GPS unavailable")
                    .font(.system(size: layout.s(14), weight: .semibold))
                    .foregroundStyle(AppTheme.muted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(layout.s(14))
        .appCard(elevated: false)
    }

    private var satelliteDisclosure: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showSatelliteHelp.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .foregroundStyle(AppTheme.accent)
                    Text("No cell signal?")
                        .font(.system(size: layout.s(14), weight: .bold))
                        .foregroundStyle(AppTheme.accent)
                    Spacer()
                    Image(systemName: showSatelliteHelp ? "chevron.up" : "chevron.down")
                        .font(.system(size: layout.s(12), weight: .semibold))
                        .foregroundStyle(AppTheme.muted)
                }
            }
            .buttonStyle(.plain)
            .padding(layout.s(14))

            if showSatelliteHelp {
                VStack(spacing: layout.s(8)) {
                    Text("RedMed shows GPS only. Satellite emergency calling is built into your phone — RedMed cannot open or control it.")
                        .font(.system(size: layout.s(11)))
                        .foregroundStyle(AppTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("iPhone 14+ (iOS 16.1+): hold Side + Volume until Emergency SOS appears, or Settings → Emergency SOS. Guide: https://support.apple.com/en-us/102669")
                        .font(.system(size: layout.s(11)))
                        .foregroundStyle(AppTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Tell the dispatcher street names or landmarks if you can, even with GPS.")
                        .font(.system(size: layout.s(11), weight: .medium))
                        .foregroundStyle(AppTheme.ink.opacity(0.75))
                        .fixedSize(horizontal: false, vertical: true)

                    Call911Button(title: "Open Phone · dial 911", secondary: true)
                }
                .padding(.horizontal, layout.s(14))
                .padding(.bottom, layout.s(14))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(AppTheme.cardBg)
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
