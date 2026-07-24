import SwiftUI

/// Owner My ID tab — read-only summary; Edit is open until this device has a
/// saved profile, then Face ID / Touch ID (passcode fallback) is required.
///
/// Per-device: a new install starts unlocked for setup. After the owner saves
/// a profile name on this phone, Edit stays gated going forward. Clearing the
/// profile disarms the latch so setup can run again. Emergency card / NFC
/// scan paths are never gated.
struct MyIDView: View {
    @EnvironmentObject var store: ProfileStore
    @EnvironmentObject var link: BraceletLinkStore
    @Environment(\.scenePhase) private var scenePhase

    /// Device-local latch in AppStorage — empty on every new install.
    @AppStorage("redMedEditLockArmed") private var lockArmed = false

    @State private var authInProgress = false
    @State private var showingEditSheet = false
    @State private var showingBraceletSetup = false

    private var profileIsSetUp: Bool {
        !store.profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

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
        .onAppear { syncLockLatch() }
        .onChange(of: store.profile.name) { _ in syncLockLatch() }
        .onChange(of: showingEditSheet) { isShowing in
            // After a successful setup save, arm once the sheet closes.
            if !isShowing { syncLockLatch() }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background { showingEditSheet = false }
        }
        .sheet(isPresented: $showingBraceletSetup) {
            BraceletSetupView()
        }
        .sheet(isPresented: $showingEditSheet) {
            EditProfileView(embedded: false)
        }
    }

    /// Arm when this device has a named profile; disarm when cleared.
    private func syncLockLatch() {
        lockArmed = profileIsSetUp
    }

    @MainActor
    private func requestEdit() async {
        guard !authInProgress else { return }
        // First-time / cleared device: edit freely until a profile exists.
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
