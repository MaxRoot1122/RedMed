import SwiftUI

struct WriteTagView: View {
    @Environment(\.layoutMetrics) private var layout
    @EnvironmentObject var store: ProfileStore
    @StateObject private var writer = NFCWriter()
    @StateObject private var importReader = NFCReader()
    @State private var pendingRead: MedicalProfile?
    @State private var showingReadConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: layout.space2XL) {
                    hero

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
                    .buttonStyle(PrimaryButtonStyle(enabled: !store.profile.name.isEmpty && !writer.isWriting))
                    .disabled(store.profile.name.isEmpty || writer.isWriting)

                    if store.profile.name.isEmpty {
                        Text("Add your name on My ID before writing a tag.")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(AppTheme.accent)
                            .multilineTextAlignment(.center)
                    }

                    scanSection
                    importSection
                }
                .padding(.horizontal, layout.screenPad)
                .padding(.top, layout.spaceSM)
                .padding(.bottom, layout.screenBottomLarge)
            }
            .screenAtmosphere()
            .navigationTitle("NFC")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    BrandMark(size: .nav)
                }
            }
            .confirmationDialog(
                "Replace this device's RedMed with the tag's data?",
                isPresented: $showingReadConfirm,
                titleVisibility: .visible
            ) {
                Button("Replace", role: .destructive) {
                    replaceFromTag()
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

    private func replaceFromTag() {
        if let pendingRead { store.profile = pendingRead }
        pendingRead = nil
    }

    private var hero: some View {
        VStack(spacing: layout.s(18)) {
            ZStack {
                Circle()
                    .fill(AppTheme.medicalSoft)
                    .frame(width: layout.nfcHeroInner, height: layout.nfcHeroInner)
                Circle()
                    .stroke(AppTheme.medical.opacity(0.2), lineWidth: 1.5)
                    .frame(width: layout.nfcHeroOuter, height: layout.nfcHeroOuter)
                Image(systemName: "wave.3.right.circle.fill")
                    .font(layout.nfcGlyphFont())
                    .foregroundStyle(AppTheme.medical)
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.top, layout.spaceMD)

            VStack(spacing: layout.spaceSM) {
                Text("Write Tag")
                    .font(layout.heroTitleFont())
                    .tracking(-0.4)
                    .foregroundStyle(AppTheme.ink)
                Text("Hold your iPhone to the bracelet once to program the passive chip. The band stores your card (no battery) until a smartphone taps to read it in a browser.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
    }

    /// First-responder path — opens native emergency card, does not touch My ID.
    private var scanSection: some View {
        VStack(spacing: layout.s(14)) {
            HStack {
                Rectangle().fill(AppTheme.line).frame(height: 1)
                Text("SCAN CARD")
                    .font(.caption2.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(AppTheme.muted)
                Rectangle().fill(AppTheme.line).frame(height: 1)
            }

            Text("First responder: open the person's medical ID in RedMed without changing your own profile.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.muted)
                .multilineTextAlignment(.center)

            ScanEmergencyCardControl(title: "Scan emergency bracelet")
        }
        .padding(.top, layout.spaceSM)
    }

    /// Owner path — pull tag data onto this phone's My ID.
    private var importSection: some View {
        VStack(spacing: layout.s(14)) {
            HStack {
                Rectangle().fill(AppTheme.line).frame(height: 1)
                Text("OR IMPORT")
                    .font(.caption2.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(AppTheme.muted)
                Rectangle().fill(AppTheme.line).frame(height: 1)
            }

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
