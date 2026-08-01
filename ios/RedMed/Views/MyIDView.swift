import SwiftUI

/// Owner My ID tab — artifact nav chrome + card-group summary.
struct MyIDView: View {
    @Environment(\.layoutMetrics) private var layout
    @EnvironmentObject var store: ProfileStore
    @EnvironmentObject var link: BraceletLinkStore
    @Environment(\.scenePhase) private var scenePhase
    @Binding var selectedTab: OwnerTab

    @State private var showingEditSheet = false
    @State private var showingHowItWorks = false
    @AppStorage("redMedUseConsent") private var useConsentAccepted = false
    @State private var showingConsent = false

    var body: some View {
        VStack(spacing: 0) {
            navBar

            ProfileSummaryView(
                profile: store.profile,
                link: link,
                onBraceletTap: { selectedTab = .nfc },
                onHelpTap: { showingHowItWorks = true }
            )
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background { showingEditSheet = false }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditProfileView(embedded: false)
                .withLayoutMetrics()
        }
        .sheet(isPresented: $showingHowItWorks) {
            HelpMenuView()
                .withLayoutMetrics()
        }
        .fullScreenCover(isPresented: $showingConsent) {
            UseConsentView {
                useConsentAccepted = true
                showingConsent = false
                showingEditSheet = true
            }
            .withLayoutMetrics()
        }
    }

    private var navBar: some View {
        HStack {
            Image("BrandWordmark")
                .resizable()
                .scaledToFit()
                .frame(height: layout.s(22))
                .accessibilityLabel("RedMed")
            Spacer()
            Button(action: beginEdit) {
                Text("Edit")
                    .font(.system(size: layout.s(17)))
                    .foregroundStyle(AppTheme.accent)
            }
            .accessibilityLabel("Edit")
        }
        .padding(.horizontal, layout.s(14))
        .frame(height: layout.s(44))
        .background(Color.white.opacity(0.9))
        .overlay(alignment: .bottom) {
            Divider().overlay(AppTheme.ink.opacity(0.08))
        }
    }

    private func beginEdit() {
        if useConsentAccepted {
            showingEditSheet = true
        } else {
            showingConsent = true
        }
    }
}

#Preview {
    MyIDView(selectedTab: .constant(.myID))
        .environmentObject(ProfileStore())
        .environmentObject(BraceletLinkStore())
        .withLayoutMetrics()
}
