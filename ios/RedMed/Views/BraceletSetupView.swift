import SwiftUI

/// Owner-only bracelet pairing — read blank band, write profile, stranger tap works without app.
struct BraceletSetupView: View {
    @Environment(\.layoutMetrics) private var layout
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: ProfileStore
    @EnvironmentObject var link: BraceletLinkStore
    @StateObject private var writer = NFCWriter()
    @StateObject private var reader = NFCReader()

    @State private var deviceName = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: layout.spaceXL) {
                    VStack(alignment: .leading, spacing: layout.spaceSM) {
                        Text("Your bracelet")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(AppTheme.ink)
                        Text("The band holds your card on a passive chip (no battery, no broadcast). When any iPhone taps, Safari opens your emergency card — no RedMed install for them.")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    setupStep(number: 1, title: "Fill My ID", detail: "Name, allergies, meds, and contacts on the previous screen. Tap Save.")
                    setupStep(number: 2, title: "Program your band", detail: "Write once — your card is stored on the passive chip. Any iPhone tap powers the chip and opens Safari.")
                    setupStep(number: 3, title: "Done", detail: "In an emergency, a stranger taps the band with any iPhone. Safari opens your emergency card — they see what you saved.")

                    if link.isLinked {
                        SoftStatusChip(text: "Bracelet linked on this phone", warning: false)
                    }

                    TextField("Device name", text: $deviceName)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: deviceName) { newValue in
                            if link.isLinked { link.updateName(newValue) }
                        }

                    if !writer.statusMessage.isEmpty {
                        Text(writer.statusMessage)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(writer.verified ? AppTheme.ok : (writer.success ? AppTheme.ink : AppTheme.accent))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }

                    if writer.verified {
                        SoftStatusChip(text: "Chip verified — any iPhone tap opens your card in Safari", warning: false)
                    }

                    Button {
                        reader.readTag { _, urlString in
                            link.link(name: deviceName, url: urlString)
                        }
                    } label: {
                        Label("Read bracelet (add device)", systemImage: "dot.radiowaves.left.and.right")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(reader.isReading)

                    Button {
                        guard let url = ProfileLinkBuilder.buildURL(profile: store.profile, baseURL: AppConfig.medicalCardBaseURL) else { return }
                        writer.writeURL(url.absoluteString)
                    } label: {
                        Label(writer.isWriting ? "Hold iPhone near band…" : "Write profile to bracelet", systemImage: "wave.3.right")
                    }
                    .buttonStyle(PrimaryButtonStyle(enabled: !store.profile.name.isEmpty && !writer.isWriting))
                    .disabled(store.profile.name.isEmpty || writer.isWriting)

                    if store.profile.name.isEmpty {
                        Text("Add your name on My ID and Save first.")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(AppTheme.accent)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    let note = ProfileLinkBuilder.capacityNote(for: store.profile)
                    SoftStatusChip(text: note.text, warning: note.warn)

                    BraceletSyncInstructions()
                }
                .padding(layout.screenPad)
                .padding(.bottom, layout.screenBottom)
                .reactiveScrollTrack()
            }
            .reactiveScrollChrome()
            .screenAtmosphere()
            .navigationTitle("Bracelet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .bold()
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .onAppear {
                if !link.deviceName.isEmpty {
                    deviceName = link.deviceName
                } else if deviceName.isEmpty {
                    deviceName = "My bracelet"
                }
            }
            .onChange(of: writer.verified) { verified in
                guard verified,
                      let url = ProfileLinkBuilder.buildURL(profile: store.profile, baseURL: AppConfig.medicalCardBaseURL) else { return }
                link.link(name: deviceName, url: url.absoluteString)
            }
            .onChange(of: writer.success) { success in
                guard success, !writer.verified,
                      let url = ProfileLinkBuilder.buildURL(profile: store.profile, baseURL: AppConfig.medicalCardBaseURL) else { return }
                link.link(name: deviceName, url: url.absoluteString)
            }
        }
    }

    private func setupStep(number: Int, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: layout.spaceMD) {
            Text("\(number)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: layout.stepBadge, height: layout.stepBadge)
                .background(LinearGradient(colors: [Color(red: 1, green: 0.45, blue: 0.55), AppTheme.accent], startPoint: .top, endPoint: .bottom))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: layout.spaceXS) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.ink)
                Text(detail)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(AppTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(layout.s(14))
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }
}

#Preview {
    BraceletSetupView()
        .environmentObject(ProfileStore())
        .environmentObject(BraceletLinkStore())
        .withLayoutMetrics()
}
