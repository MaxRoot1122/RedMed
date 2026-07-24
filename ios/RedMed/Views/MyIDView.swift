import SwiftUI

/// Owner My ID tab — read-only profile summary with Edit opening the form.
struct MyIDView: View {
    @EnvironmentObject var store: ProfileStore
    @EnvironmentObject var link: BraceletLinkStore
    @Environment(\.scenePhase) private var scenePhase

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
                            showingEditSheet = true
                        } label: {
                            Text("Edit").bold()
                        }
                        .foregroundStyle(AppTheme.accent)
                        .accessibilityLabel("Edit")
                    }
                }
        }
        .tint(AppTheme.accent)
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
}

#Preview {
    MyIDView()
        .environmentObject(ProfileStore())
        .environmentObject(BraceletLinkStore())
}
