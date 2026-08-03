import SwiftUI
import UIKit

/// Dedicated footer tab whose only job is a single tap to dial 911 —
/// no scrolling, no GPS, no secondary steps. Reuses `EmergencySummaryBuilder.call911URL`,
/// the same `telprompt:` link `LocationView`'s "Call 911" button uses, so iOS still
/// shows its native confirm sheet before the call is placed.
struct Call911TabView: View {
    var body: some View {
        ArtifactTabShell(hideHeader: true) {
            VStack(spacing: 18) {
                Spacer(minLength: 40)

                VStack(spacing: 6) {
                    Text("One tap. Straight to 911.")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.redmedDark)
                        .multilineTextAlignment(.center)
                    Text("iPhone will ask you to confirm before the call is placed.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.redmedMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)

                Button {
                    if let url = EmergencySummaryBuilder.call911URL {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Call 911")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 26)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 1, green: 0.447, blue: 0.537), .redmedAccent],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.redmedAccent.opacity(0.28), radius: 10, y: 5)
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 60)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 24)
        }
    }
}

#Preview {
    Call911TabView()
        .environmentObject(ProfileStore())
}
