import SwiftUI

/// Owner-only bracelet pairing — artifact NFC layout on CoreNFC read/write.
struct BraceletSetupView: View {
    @Environment(\.layoutMetrics) private var layout
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @EnvironmentObject var store: ProfileStore
    @EnvironmentObject var link: BraceletLinkStore
    @StateObject private var writer = NFCWriter()
    @StateObject private var reader = NFCReader()
    @StateObject private var verifyReader = NFCReader()

    @State private var deviceName = ""

    private var profileReady: Bool {
        !store.profile.name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: layout.spaceMD) {
                    VStack(spacing: layout.s(4)) {
                        Text("Bracelet")
                            .font(layout.heroTitleFont())
                            .foregroundStyle(AppTheme.ink)
                        Text("Link once on this iPhone. Hold the band to write — any phone tap opens your card.")
                            .font(layout.subheadlineFont(weight: .medium))
                            .foregroundStyle(AppTheme.muted)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .frame(maxWidth: layout.s(275))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, layout.spaceSM)
                    .padding(.bottom, layout.s(6))

                    artifactInfoChip("Tap the band · phone opens your card · no app for readers")

                    if link.isLinked {
                        artifactInfoChip("Bracelet linked on this phone")
                    }

                    deviceNameCard

                    let note = ProfileLinkBuilder.capacityNote(for: store.profile)
                    artifactInfoChip(note.text)

                    if !writer.statusMessage.isEmpty {
                        Text(writer.statusMessage)
                            .font(layout.captionFont(weight: .semibold))
                            .foregroundStyle(writer.verified ? AppTheme.ok : AppTheme.ink)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        guard let url = ProfileLinkBuilder.buildURL(profile: store.profile, baseURL: AppConfig.medicalCardBaseURL) else { return }
                        writer.writeURL(url.absoluteString)
                    } label: {
                        HStack(spacing: layout.spaceSM) {
                            Image(systemName: "wave.3.right")
                            Text(writer.isWriting ? "Hold near tag…" : "Write profile to bracelet")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(enabled: profileReady && !writer.isWriting))
                    .disabled(!profileReady || writer.isWriting)

                    if !profileReady {
                        Text("Add your name on My ID and Save first.")
                            .font(layout.captionFont(weight: .semibold))
                            .foregroundStyle(AppTheme.accent)
                            .multilineTextAlignment(.center)
                    }

                    if profileReady {
                        Button {
                            openHostedPreview()
                        } label: {
                            Label("Preview hosted card in Safari", systemImage: "safari")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }

                    verifyCard

                    Button {
                        reader.readTag { _, urlString in
                            link.link(name: deviceName, url: urlString)
                        }
                    } label: {
                        Label(
                            reader.isReading ? "Hold near bracelet…" : "Read bracelet (add device)",
                            systemImage: "dot.radiowaves.left.and.right"
                        )
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(reader.isReading)

                    syncCard
                }
                .padding(.horizontal, layout.screenPad)
                .padding(.bottom, layout.screenBottomLarge)
                .reactiveScrollTrack()
            }
            .reactiveScrollChrome()
            .scrollIndicators(.visible, axes: .vertical)
            .screenAtmosphere()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Bracelet")
                        .font(layout.navTitleFont())
                        .foregroundStyle(AppTheme.ink)
                }
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

    private var deviceNameCard: some View {
        VStack(alignment: .leading, spacing: layout.spaceSM) {
            Text("DEVICE NAME")
                .font(.system(size: layout.s(10), weight: .bold))
                .kerning(1.1)
                .foregroundStyle(AppTheme.muted)
            TextField("My bracelet", text: $deviceName)
                .font(layout.subheadlineFont(weight: .semibold))
                .foregroundStyle(AppTheme.ink)
                .onChange(of: deviceName) { newValue in
                    if link.isLinked { link.updateName(newValue) }
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(layout.spaceLG)
        .appCard(elevated: false)
    }

    private var verifyCard: some View {
        VStack(alignment: .leading, spacing: layout.s(10)) {
            Text("VERIFY")
                .font(.system(size: layout.s(10), weight: .bold))
                .kerning(1.1)
                .foregroundStyle(AppTheme.muted)
                .padding(.horizontal, layout.s(10))
                .padding(.vertical, layout.s(5))
                .background(Capsule().fill(AppTheme.mutedSoft))

            Text("After writing, scan your band to see the same emergency card a stranger gets.")
                .font(layout.captionFont(weight: .medium))
                .foregroundStyle(AppTheme.muted)
                .lineSpacing(3)

            Button {
                verifyReader.readTag(
                    alertMessage: "Hold your iPhone near your RedMed bracelet to verify the write."
                ) { _, urlString in
                    Task { @MainActor in
                        ProfileLinkBuilder.openHostedCard(urlString: urlString)
                    }
                }
            } label: {
                Text(verifyReader.isReading ? "Hold near bracelet…" : "Scan your bracelet")
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(verifyReader.isReading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(layout.spaceLG)
        .appCard(elevated: false)
    }

    private var syncCard: some View {
        VStack(alignment: .leading, spacing: layout.s(10)) {
            Text("Keep your band in sync")
                .font(layout.subheadlineFont(weight: .bold))
                .foregroundStyle(AppTheme.ink)
            syncBullet("Fill My ID, tap Save, then hold your phone to the band when prompted.")
            syncBullet("Save after every edit — the chip stores your hosted card URL.")
            syncBullet("Passersby tap the band. Their phone opens the card. No RedMed install.")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(layout.s(14))
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: layout.s(14), style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: layout.s(14), style: .continuous)
                .stroke(AppTheme.line, lineWidth: 1)
        )
    }

    private func artifactInfoChip(_ text: String) -> some View {
        Text(text)
            .font(layout.captionFont(weight: .semibold))
            .foregroundStyle(AppTheme.muted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, layout.s(14))
            .padding(.vertical, layout.s(10))
            .background(Color.white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: layout.s(14), style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: layout.s(14), style: .continuous)
                    .stroke(AppTheme.line, lineWidth: 1)
            )
    }

    private func syncBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: layout.spaceSM) {
            Text("•")
                .font(layout.captionFont(weight: .bold))
                .foregroundStyle(AppTheme.accent)
            Text(text)
                .font(layout.captionFont(weight: .medium))
                .foregroundStyle(AppTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func openHostedPreview() {
        guard let url = ProfileLinkBuilder.previewURL(profile: store.profile) else { return }
        openURL(url)
    }
}

#Preview {
    BraceletSetupView()
        .environmentObject(ProfileStore())
        .environmentObject(BraceletLinkStore())
        .withLayoutMetrics()
}
