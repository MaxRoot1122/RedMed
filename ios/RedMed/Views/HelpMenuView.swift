import SwiftUI

/// Policies sheet — matches artifact HelpMenuView (My ID → How it works).
struct HelpMenuView: View {
    @Environment(\.layoutMetrics) private var layout
    @Environment(\.dismiss) private var dismiss
    @State private var showHowItWorks = false

    var body: some View {
        NavigationStack {
            List {
                Link(destination: URL(string: AppConfig.privacyPolicyURL)!) {
                    Text("Privacy Policy")
                }
                Link(destination: URL(string: AppConfig.termsOfServiceURL)!) {
                    Text("Terms of Service")
                }
                Button("How It Works") { showHowItWorks = true }
                Link(destination: URL(string: "https://github.com/RedmMed/RedMed/blob/main/SECURITY.md")!) {
                    Text("Security")
                }
            }
            .navigationTitle("Policies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .sheet(isPresented: $showHowItWorks) {
                HowItWorksView()
                    .withLayoutMetrics()
            }
        }
        .tint(AppTheme.accent)
    }
}

#Preview {
    HelpMenuView()
        .withLayoutMetrics()
}
