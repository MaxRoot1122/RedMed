import SwiftUI
import UIKit

struct LocationView: View {
    @EnvironmentObject var store: ProfileStore
    @StateObject private var locationManager = LocationManager()
    @State private var copiedCoords = false
    @State private var showCallContactPicker = false
    @StateObject private var scanReader = NFCReader()

    var body: some View {
        ArtifactTabShell(hideHeader: true) {
            VStack(alignment: .leading, spacing: 8) {
                    Text("Find 911")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.redmedDark)
                    Text("Call first. Share GPS second.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.redmedMuted)
                        .padding(.bottom, 2)

                    PrimaryButton(title: "Call 911") {
                        if let url = EmergencySummaryBuilder.call911URL {
                            UIApplication.shared.open(url)
                        }
                    }

                    SecondaryButton("Scan emergency bracelet") { startScan() }
                    Text("Tap the band — their browser opens the emergency card.")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.redmedMuted)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    SecondaryButton("Call emergency contacts") {
                        showCallContactPicker = true
                    }
                    .disabled(callableContacts.isEmpty)
                    Text("Pick a saved contact — iPhone asks before placing the call.")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.redmedMuted)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 4)

                    ArtifactGPSCard(
                        coordinate: locationManager.coordinate,
                        accuracy: locationManager.accuracy,
                        heading: locationManager.heading,
                        altitude: locationManager.altitude
                    )
                    .padding(.vertical, 4)

                    Button { copyCoordinates() } label: {
                        Text(copiedCoords ? "Copied!" : "Copy coordinates")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.redmedDark)
                            .clipShape(Capsule())
                    }

                    InfoCard(
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

                    InfoCard(
                        icon: "info.circle.fill",
                        title: "What to Tell 911",
                        numbered: false,
                        items: [
                            "Your exact location — read the GPS coordinates above.",
                            "Number of people injured and visible injuries."
                        ]
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
        }
        .onAppear { locationManager.requestLocation() }
        .onDisappear { locationManager.stopUpdating() }
        .sheet(isPresented: $showCallContactPicker) {
            ArtifactContactCallSheet(contacts: callableContacts) {
                showCallContactPicker = false
            }
        }
    }

    private var callableContacts: [EmergencyContact] {
        store.profile.contacts.filter {
            !EmergencySummaryBuilder.normalizedPhone($0.phone).isEmpty
        }
    }

    private func startScan() {
        scanReader.readTag(
            alertMessage: "Hold your iPhone near the person's RedMed bracelet to open their emergency card."
        ) { profile, _ in
            NotificationCenter.default.post(name: .redMedShowEmergencyCard, object: profile)
        }
    }

    private func copyCoordinates() {
        guard let c = locationManager.coordinate else { return }
        UIPasteboard.general.string = LocationFormatting.coordsCopyText(
            latitude: c.latitude,
            longitude: c.longitude
        )
        copiedCoords = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copiedCoords = false }
    }
}

private struct ArtifactContactCallSheet: View {
    let contacts: [EmergencyContact]
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            List(contacts) { contact in
                if let url = EmergencySummaryBuilder.telURL(phone: contact.phone) {
                    Link(destination: url) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(contact.name.isEmpty ? "Contact" : contact.name)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.redmedDark)
                                if !contact.rel.isEmpty {
                                    Text(contact.rel)
                                        .font(.system(size: 14))
                                        .foregroundColor(.redmedMuted)
                                }
                            }
                            Spacer()
                            Image(systemName: "phone.fill").foregroundColor(.redmedAccent)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Select a contact to call")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
            }
        }
    }
}

#Preview {
    LocationView()
        .environmentObject(ProfileStore())
}
