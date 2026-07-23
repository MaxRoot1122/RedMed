import SwiftUI

/// Owner My ID tab — read-only profile summary with a gated "Edit" button.
///
/// Editing is open during initial setup (no bracelet linked yet). Once the
/// owner completes NFC tag setup — `BraceletSetupView` calls
/// `link.link(...)` after a verified write or read, flipping
/// `link.isLinked` to true — the Edit button requires Face ID / Touch ID
/// (with device-passcode fallback) before the editable form opens.
///
/// Only this owner-management tab is gated. The emergency card that first
/// responders read via NFC/URL (`ScannedCardView`) is a separate path and
/// stays ungated on purpose.
struct MyIDView: View {
    @EnvironmentObject var store: ProfileStore
    @EnvironmentObject var link: BraceletLinkStore
    @Environment(\.scenePhase) private var scenePhase

    /// Persisted latch: becomes true once the owner has linked an NFC
    /// bracelet. Before this, editing is open; after, editing requires
    /// authentication. Shared with `WriteTagView`, which gates re-writing
    /// or overwriting-from-tag behind the same latch.
    @AppStorage("redMedEditLockArmed") private var lockArmed = false

    @State private var authInProgress = false
    @State private var showingEditSheet = false
    @State private var showingBraceletSetup = false

    var body: some View {
        NavigationStack {
            ProfileSummaryView(profile: store.profile, link: link)
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showingBraceletSetup = true
                        } label: {
                            BraceletToolbarButton(link: link)
                        }
                        .accessibilityLabel("Bracelet setup")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task { await requestEdit() }
                        } label: {
                            if authInProgress {
                                ProgressView()
                            } else {
                                Text("Edit").bold()
                            }
                        }
                        .foregroundStyle(AppTheme.accent)
                        .disabled(authInProgress)
                        .accessibilityLabel(lockArmed ? "Edit (Face ID required)" : "Edit")
                    }
                }
        }
        .tint(AppTheme.accent)
        .onAppear {
            // Catch up existing users: if a bracelet was already linked
            // before this lock existed, treat setup as already complete.
            if link.isLinked { lockArmed = true }
        }
        .onChange(of: link.isLinked) { isLinked in
            if isLinked { lockArmed = true }
        }
        .onChange(of: scenePhase) { phase in
            // Drop out of an open edit session the moment the app backgrounds.
            if phase == .background { showingEditSheet = false }
        }
        .sheet(isPresented: $showingBraceletSetup) {
            BraceletSetupView()
        }
        .sheet(isPresented: $showingEditSheet) {
            EditProfileView(embedded: false)
        }
    }

    /// Gate for the Edit button: open during initial setup (no tag linked
    /// yet), otherwise requires Face ID / Touch ID before the form opens.
    @MainActor
    private func requestEdit() async {
        guard !authInProgress else { return }
        guard lockArmed else {
            showingEditSheet = true
            return
        }
        authInProgress = true
        let ok = await BiometricGate.authenticate(reason: "Unlock to edit your medical ID")
        authInProgress = false
        if ok { showingEditSheet = true }
    }
}

#Preview {
    MyIDView()
        .environmentObject(ProfileStore())
        .environmentObject(BraceletLinkStore())
}
