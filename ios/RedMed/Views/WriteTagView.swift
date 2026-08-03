import SwiftUI

struct WriteTagView: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject var store: ProfileStore
    @StateObject private var writer = NFCWriter()
    @StateObject private var verifyReader = NFCReader()
    @StateObject private var importReader = NFCReader()
    @State private var showWriteOverlay = false
    @State private var pendingRead: MedicalProfile?
    @State private var showingReadConfirm = false

    private var profileReady: Bool {
        !store.profile.name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ArtifactTabShell {
            VStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Text("NFC Bracelet")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.redmedDark)
                        Text("iPhone only for setup. Fill My ID, write the band once — CoreNFC, Face ID, done.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.redmedMuted)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .frame(maxWidth: 275)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 6)

                    infoChip("Tap the band · phone opens your card · no app for readers")
                    infoChip(ProfileLinkBuilder.capacityNote(for: store.profile).text)

                    if !writer.statusMessage.isEmpty {
                        Text(writer.statusMessage)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(writer.success ? .redmedAccent : .redmedDark)
                            .multilineTextAlignment(.center)
                    }

                    Button { beginWrite() } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "wave.3.right")
                            Text(writer.isWriting ? "Hold near tag…" : "Write to NFC tag")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 1, green: 0.447, blue: 0.537), .redmedAccent],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.redmedAccent.opacity(0.28), radius: 7, y: 4)
                    }
                    .disabled(!profileReady || writer.isWriting)
                    .opacity(profileReady && !writer.isWriting ? 1 : 0.5)
                    .padding(.top, 4)

                    if !profileReady {
                        Text("Add your name on RedMed before writing a tag.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.redmedAccent)
                            .multilineTextAlignment(.center)
                    }

                    if profileReady {
                        SecondaryButton("Preview hosted card in Safari", icon: "safari") {
                            guard let url = ProfileLinkBuilder.previewURL(profile: store.profile) else { return }
                            openURL(url)
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("VERIFY")
                            .font(.system(size: 10, weight: .bold))
                            .kerning(1.1)
                            .foregroundColor(.redmedMuted)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Capsule().fill(Color.redmedMuted.opacity(0.1)))

                        Text("After writing, scan your band here to see the same emergency card a stranger gets.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.redmedMuted)
                            .lineSpacing(3)

                        SecondaryButton(verifyReader.isReading ? "Hold near bracelet…" : "Scan your bracelet") {
                            verifyReader.readTag(
                                alertMessage: "Hold your iPhone near your RedMed bracelet to verify the write."
                            ) { _, urlString in
                                Task { @MainActor in
                                    ProfileLinkBuilder.openHostedCard(urlString: urlString)
                                }
                            }
                        }
                        .disabled(verifyReader.isReading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.redmedSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.redmedDivider, lineWidth: 1))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Keep your band in sync")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.redmedDark)
                        syncBullet("Link your bracelet once (My ID → bracelet icon → write/read).")
                        syncBullet("Save after every edit and hold your phone to the band when prompted.")
                        syncBullet("If you cancel the NFC prompt, the band stays stale until you save again.")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.redmedDivider, lineWidth: 1))

                    dividerLabel("SCAN CARD")

                    Text("Opens the same hosted card in Safari that passersby get when they tap the band — no app needed.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.redmedMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)

                    SecondaryButton("Scan emergency bracelet", icon: "qrcode.viewfinder") {
                        verifyReader.readTag(
                            alertMessage: "Hold your iPhone near the person's RedMed bracelet to open their emergency card."
                        ) { _, urlString in
                            Task { @MainActor in
                                ProfileLinkBuilder.openHostedCard(urlString: urlString)
                            }
                        }
                    }
                    .disabled(verifyReader.isReading)

                    dividerLabel("OR IMPORT")

                    Text("Already own a written tag? Pull it onto this phone's My ID.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.redmedMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)

                    SecondaryButton(importReader.isReading ? "Hold near tag…" : "Import tag onto this phone", icon: "arrow.down.circle") {
                        importReader.readTag(
                            alertMessage: "Hold your iPhone near your tag to import it onto this phone."
                        ) { profile, _ in
                            pendingRead = profile
                            showingReadConfirm = true
                        }
                    }
                    .disabled(importReader.isReading)
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 16)
        }
        .overlay {
            if showWriteOverlay { NFCWriteOverlay { showWriteOverlay = false } }
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

    private func beginWrite() {
        guard profileReady,
              let url = ProfileLinkBuilder.buildURL(profile: store.profile, baseURL: AppConfig.medicalCardBaseURL) else { return }
        showWriteOverlay = true
        writer.writeURL(url.absoluteString)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showWriteOverlay = false
        }
    }

    @MainActor
    private func replaceFromTagAfterAuth() async {
        let ok = await BiometricGate.authenticate(reason: "Confirm replacing your medical ID from the tag")
        guard ok, let pendingRead else { return }
        store.profile = pendingRead
        self.pendingRead = nil
    }

    @ViewBuilder
    private func infoChip(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.redmedMuted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(Color.white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.redmedDivider, lineWidth: 1))
    }

    @ViewBuilder
    private func syncBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•").font(.system(size: 13, weight: .bold)).foregroundColor(.redmedAccent)
            Text(text).font(.system(size: 13, weight: .medium)).foregroundColor(.redmedMuted).lineSpacing(3)
        }
    }

    @ViewBuilder
    private func dividerLabel(_ text: String) -> some View {
        HStack(spacing: 10) {
            Rectangle().fill(Color.redmedDivider).frame(height: 0.5)
            Text(text).font(.system(size: 10, weight: .bold)).kerning(1).foregroundColor(.redmedMuted)
            Rectangle().fill(Color.redmedDivider).frame(height: 0.5)
        }
    }
}

#Preview {
    WriteTagView()
        .environmentObject(ProfileStore())
}
