import SwiftUI

struct WriteTagView: View {
    @Environment(\.layoutMetrics) private var layout
    @EnvironmentObject var store: ProfileStore
    @StateObject private var writer = NFCWriter()
    @StateObject private var reader = NFCReader()
    @State private var pendingRead: MedicalProfile?
    @State private var showingReadConfirm = false

    /// Same latch as the My ID edit-lock: flips true once `BraceletLinkStore`
    /// links a bracelet (see MyIDView). Before that, initial NFC tag setup
    /// stays open; after, re-writing or overwriting-from-tag requires Face ID.
    @AppStorage("redMedEditLockArmed") private var lockArmed = false
    @State private var authInProgress = false

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
                        Task { await gatedWrite() }
                    } label: {
                        Label(
                            writer.isWriting ? "Hold near tag…" : "Write to NFC tag",
                            systemImage: "wave.3.right"
                        )
                    }
                    .buttonStyle(PrimaryButtonStyle(enabled: !store.profile.name.isEmpty && !writer.isWriting && !authInProgress))
                    .disabled(store.profile.name.isEmpty || writer.isWriting || authInProgress)

                    if store.profile.name.isEmpty {
                        Text("Add your name on My ID before writing a tag.")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(AppTheme.accent)
                            .multilineTextAlignment(.center)
                    }

                    readSection
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
                    Task { await gatedReplace() }
                }
                Button("Cancel", role: .cancel) { pendingRead = nil }
            } message: {
                Text("This overwrites what's currently saved on My ID with what was read from the tag.")
            }
        }
    }

    /// Authenticates (only if the edit-lock is armed) then writes the profile to a tag.
    @MainActor
    private func gatedWrite() async {
        guard let url = ProfileLinkBuilder.buildURL(profile: store.profile, baseURL: AppConfig.medicalCardBaseURL) else { return }
        guard await passesGate() else { return }
        writer.writeURL(url.absoluteString)
    }

    /// Authenticates (only if the edit-lock is armed) then overwrites the local profile from a read tag.
    @MainActor
    private func gatedReplace() async {
        guard await passesGate() else { pendingRead = nil; return }
        if let pendingRead { store.profile = pendingRead }
        pendingRead = nil
    }

    /// Returns true if the action may proceed: open during initial setup,
    /// otherwise requires Face ID / Touch ID (with passcode fallback).
    @MainActor
    private func passesGate() async -> Bool {
        guard lockArmed else { return true }
        authInProgress = true
        let ok = await BiometricGate.authenticate(reason: "Unlock to update your medical ID")
        authInProgress = false
        return ok
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

    private var readSection: some View {
        VStack(spacing: layout.s(14)) {
            HStack {
                Rectangle().fill(AppTheme.line).frame(height: 1)
                Text("OR READ")
                    .font(.caption2.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(AppTheme.muted)
                Rectangle().fill(AppTheme.line).frame(height: 1)
            }

            Text("Already have a written tag? Pull it onto this phone.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.muted)
                .multilineTextAlignment(.center)

            if !reader.statusMessage.isEmpty {
                Text(reader.statusMessage)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.muted)
                    .multilineTextAlignment(.center)
            }

            Button {
                reader.readTag { profile, _ in
                    pendingRead = profile
                    showingReadConfirm = true
                }
            } label: {
                Label(
                    reader.isReading ? "Hold near tag…" : "Read tag onto this phone",
                    systemImage: "dot.radiowaves.left.and.right"
                )
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(reader.isReading)
        }
        .padding(.top, layout.spaceSM)
    }
}

#Preview {
    WriteTagView()
        .environmentObject(ProfileStore())
        .withLayoutMetrics()
}
