import SwiftUI

struct WriteTagView: View {
    @Environment(\.layoutMetrics) private var layout
    @Environment(\.openURL) private var openURL
    @EnvironmentObject var store: ProfileStore
    @StateObject private var writer = NFCWriter()
    @StateObject private var importReader = NFCReader()
    @State private var pendingRead: MedicalProfile?
    @State private var showingReadConfirm = false

    private var profileReady: Bool {
        !store.profile.name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: layout.spaceMD) {
                    VStack(spacing: layout.s(4)) {
                        Text("NFC Bracelet")
                            .font(.system(size: layout.s(22), weight: .bold))
                            .foregroundStyle(AppTheme.ink)
                        Text(DesignPagePlacement.nfcHeroSubtitle)
                            .font(.system(size: layout.s(14), weight: .medium))
                            .foregroundStyle(AppTheme.muted)
                            .multilineTextAlignment(.center)
                            .lineSpacing(layout.s(3))
                            .frame(maxWidth: layout.s(275))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, layout.s(8))
                    .padding(.bottom, layout.s(6))

                    SoftStatusChip(
                        text: "Tap the band · phone opens your card · no app for readers",
                        warning: false
                    )

                    let note = ProfileLinkBuilder.capacityNote(for: store.profile)
                    SoftStatusChip(text: note.text, warning: note.warn)

                    if !writer.statusMessage.isEmpty {
                        Text(writer.statusMessage)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(writer.success ? AppTheme.ok : AppTheme.ink)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                    }

                    Button {
                        writeTag()
                    } label: {
                        Label(
                            writer.isWriting ? "Hold near tag…" : "Write to NFC tag",
                            systemImage: "wave.3.right"
                        )
                    }
                    .buttonStyle(PrimaryButtonStyle(enabled: profileReady && !writer.isWriting))
                    .disabled(!profileReady || writer.isWriting)
                    .padding(.top, layout.s(4))

                    if !profileReady {
                        Text("Add your name on My ID before writing a tag.")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(AppTheme.accent)
                            .multilineTextAlignment(.center)
                    }

                    if profileReady {
                        Button {
                            guard let url = ProfileLinkBuilder.previewURL(profile: store.profile) else { return }
                            openURL(url)
                        } label: {
                            Label("Preview hosted card in Safari", systemImage: "safari")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }

                    if profileReady {
                        artifactVerifySection
                    }

                    BraceletSyncInstructions()

                    scanSection
                    importSection
                }
                .padding(.horizontal, layout.screenPad)
                .padding(.bottom, layout.screenBottomLarge)
                .reactiveScrollTrack()
            }
            .scrollIndicators(.visible, axes: .vertical)
            .background(AppTheme.pageBg)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("NFC Bracelet")
                        .font(.system(size: layout.s(17), weight: .semibold))
                        .foregroundStyle(AppTheme.ink)
                }
            }
            .overlay {
                if writer.isWriting {
                    NFCWriteOverlay { writer.cancel() }
                }
            }
            .confirmationDialog(
                "Replace this device's RedMed with the tag's data?",
                isPresented: $showingReadConfirm,
                titleVisibility: .visible
            ) {
                Button("Replace", role: .destructive) {
                    Task { await replaceFromTagAfterAuth() }
                }
                Button("Cancel", role: .cancel) { pendingRead = nil }
            } message: {
                Text("This overwrites what's currently saved on My ID with what was read from the tag.")
            }
        }
    }

    private func writeTag() {
        guard let url = ProfileLinkBuilder.buildURL(profile: store.profile, baseURL: AppConfig.medicalCardBaseURL) else { return }
        writer.writeURL(url.absoluteString)
    }

    @MainActor
    private func replaceFromTagAfterAuth() async {
        let ok = await BiometricGate.authenticate(reason: "Confirm replacing your medical ID from the tag")
        guard ok, let pendingRead else { return }
        store.profile = pendingRead
        self.pendingRead = nil
    }

    private var artifactVerifySection: some View {
        VStack(alignment: .leading, spacing: layout.s(10)) {
            Text("VERIFY")
                .font(.system(size: layout.s(10), weight: .bold))
                .kerning(1.1)
                .foregroundStyle(AppTheme.muted)
                .padding(.horizontal, layout.s(10))
                .padding(.vertical, layout.s(5))
                .background(Capsule().fill(AppTheme.mutedSoft))

            Text("After writing, scan your band here to see the same emergency card a stranger gets.")
                .font(.system(size: layout.s(13), weight: .medium))
                .foregroundStyle(AppTheme.muted)
                .lineSpacing(layout.s(3))
                .fixedSize(horizontal: false, vertical: true)

            ScanEmergencyCardControl(title: "Scan your bracelet")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(layout.s(16))
        .appCard(elevated: false)
    }

    private var scanSection: some View {
        VStack(spacing: layout.s(14)) {
            ThemeDividerLabel(text: "Scan card")

            Text("Optional: scan in RedMed for the native card view. Passersby only need to tap the band — no app.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.muted)
                .multilineTextAlignment(.center)

            ScanEmergencyCardControl(title: "Scan emergency bracelet")
        }
        .padding(.top, layout.spaceSM)
    }

    private var importSection: some View {
        VStack(spacing: layout.s(14)) {
            ThemeDividerLabel(text: "Or import")

            Text("Already own a written tag? Pull it onto this phone's My ID.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.muted)
                .multilineTextAlignment(.center)

            if !importReader.statusMessage.isEmpty {
                Text(importReader.statusMessage)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.muted)
                    .multilineTextAlignment(.center)
            }

            Button {
                importReader.readTag(
                    alertMessage: "Hold your iPhone near your tag to import it onto this phone."
                ) { profile, _ in
                    pendingRead = profile
                    showingReadConfirm = true
                }
            } label: {
                Label(
                    importReader.isReading ? "Hold near tag…" : "Import tag onto this phone",
                    systemImage: "square.and.arrow.down"
                )
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(importReader.isReading)
        }
        .padding(.top, layout.spaceSM)
    }
}

#Preview {
    WriteTagView()
        .environmentObject(ProfileStore())
        .withLayoutMetrics()
}
