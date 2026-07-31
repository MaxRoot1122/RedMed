import SwiftUI

struct HelpView: View {
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Section {
            VStack(alignment: .leading, spacing: 12) {
              HStack {
                Image(systemName: "1.circle.fill")
                  .foregroundColor(.red)
                Text("Unbox")
                  .fontWeight(.bold)
              }
              Text("Band ships ready to program — no charging, no pairing, no account.")
                .font(.callout)
                .foregroundColor(.secondary)
            }
          }
          
          Section {
            VStack(alignment: .leading, spacing: 12) {
              HStack {
                Image(systemName: "2.circle.fill")
                  .foregroundColor(.orange)
                Text("Set Up (once)")
                  .fontWeight(.bold)
              }
              Text("Enter your emergency info in the app, then write it to the band.")
                .font(.callout)
                .foregroundColor(.secondary)
            }
          }
          
          Section {
            VStack(alignment: .leading, spacing: 12) {
              HStack {
                Image(systemName: "3.circle.fill")
                  .foregroundColor(.yellow)
                Text("Wear")
                  .fontWeight(.bold)
              }
              Text("Passive NFC, no battery — it works for as long as it's worn.")
                .font(.callout)
                .foregroundColor(.secondary)
            }
          }
          
          Section {
            VStack(alignment: .leading, spacing: 12) {
              HStack {
                Image(systemName: "exclamationmark.circle.fill")
                  .foregroundColor(.red)
                Text("Distress — Bystander Taps")
                  .fontWeight(.bold)
              }
              Text("Any phone taps the band — profile and Call 911 open instantly. No app, no login.")
                .font(.callout)
                .foregroundColor(.secondary)
            }
          }
          
          Divider()
            .padding(.vertical, 8)
          
          VStack(alignment: .leading, spacing: 12) {
            Text("About RedMed")
              .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
              Text("• Passive NFC only — no battery, no broadcast")
              Text("• Medical information stored locally, never on a server")
              Text("• No account required, no login needed")
              Text("• Works as a regular band when not needed")
            }
            .font(.callout)
            .foregroundColor(.secondary)
          }
          
          Spacer()
        }
        .padding()
      }
      .navigationTitle("Help & About")
    }
  }
}

#Preview {
  HelpView()
}
