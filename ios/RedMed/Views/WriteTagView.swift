import SwiftUI

struct WriteTagView: View {
    @EnvironmentObject var store: ProfileStore
    @StateObject private var writer = NFCWriter()
    @StateObject private var reader = NFCReader()
    @State private var pendingRead: MedicalProfile?
    @State private var showingReadConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
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
                        guard let url = ProfileLinkBuilder.buildURL(profile: store.profile, baseURL: AppConfig.medicalCardBaseURL) else { return }
                        writer.writeURL(url.absoluteString)
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

                    readSection
                }
                .padding(.horizontal, AppTheme.screenPad)
                .padding(.top, 8)
                .padding(.bottom, 32)
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
                    if let pendingRead { store.profile = pendingRead }
                    pendingRead = nil
                }
                Button("Cancel", role: .cancel) { pendingRead = nil }
            } message: {
                Text("This overwrites what's currently saved on My ID with what was read from the tag.")
            }
        }
    }

    private var hero: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(AppTheme.medicalSoft)
                    .frame(width: 120, height: 120)
                Circle()
                    .stroke(AppTheme.medical.opacity(0.2), lineWidth: 1.5)
                    .frame(width: 148, height: 148)
                Image(systemName: "wave.3.right.circle.fill")
                    .font(.system(size: 56, weight: .medium))
                    .foregroundStyle(AppTheme.medical)
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.top, 12)

            VStack(spacing: 8) {
                Text("Write Tag")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
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
        VStack(spacing: 14) {
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
        .padding(.top, 8)
    }
}

#Preview {
    WriteTagView().environmentObject(ProfileStore())
}
