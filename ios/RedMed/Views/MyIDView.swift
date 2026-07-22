import SwiftUI

/// Owner My ID tab — always editable in place (no separate Edit button).
struct MyIDView: View {
    var body: some View {
        EditProfileView(embedded: true)
    }
}

#Preview {
    MyIDView()
        .environmentObject(ProfileStore())
}
