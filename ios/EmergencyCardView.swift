import SwiftUI

struct EmergencyCardView: View {
  @EnvironmentObject var profileManager: ProfileManager
  @StateObject private var nfcManager = NFCManager()
  @State private var tapDetected = false
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          // NFC Simulation Button
          Button(action: {
            nfcManager.startNFCReading()
            tapDetected = true
          }) {
            HStack {
              Image(systemName: "antenna.radiowaves.left.and.right")
              Text("Simulate NFC Tap")
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
          }
          .padding()
          
          if tapDetected || nfcManager.lastData != nil {
            // Emergency Card Display
            VStack(spacing: 0) {
              // Header
              VStack(alignment: .leading, spacing: 8) {
                HStack {
                  Image(systemName: "lock.fill")
                    .font(.caption)
                  Text("redmed.id/a4f9-2b")
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
              }
              .padding()
              .frame(maxWidth: .infinity, alignment: .leading)
              .background(Color(.systemGray6))
              
              // Content
              VStack(spacing: 12) {
                HStack {
                  Image(systemName: "cross.case.fill")
                    .font(.title3)
                    .foregroundColor(.red)
                  Text("RedMed Emergency Profile")
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Text(profileManager.name)
                  .font(.title2)
                  .fontWeight(.bold)
                
                // Call 911 Button
                Button(action: {}) {
                  HStack {
                    Image(systemName: "phone.fill")
                    Text("Call 911")
                  }
                  .frame(maxWidth: .infinity)
                  .padding(12)
                  .background(Color.red)
                  .foregroundColor(.white)
                  .cornerRadius(8)
                }
                
                // Nearest Hospital Button
                Button(action: {}) {
                  Text("Nearest Trauma Hospital")
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color(.systemGray5))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                }
                
                // Medical Info
                VStack(spacing: 0) {
                  MedicalInfoRow(label: "Blood type", value: profileManager.bloodType)
                  Divider()
                  MedicalInfoRow(label: "Allergies", value: profileManager.allergies.joined(separator: ", "))
                  Divider()
                  MedicalInfoRow(label: "Conditions", value: profileManager.conditions.joined(separator: ", "))
                  Divider()
                  if !profileManager.emergencyContacts.isEmpty {
                    MedicalInfoRow(label: "Emergency contact", value: profileManager.emergencyContacts[0].name)
                  }
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overflow(.hidden)
                
                Text("No app installed. No login. Opened straight from the tap.")
                  .font(.caption)
                  .foregroundColor(.secondary)
                  .padding(.top, 8)
              }
              .padding()
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 4)
            .padding()
          }
        }
        .navigationTitle("Emergency Card")
      }
      .alert(isPresented: $nfcManager.showAlert) {
        Alert(title: Text(nfcManager.alertMessage), dismissButton: .default(Text("OK")))
      }
    }
  }
}

struct MedicalInfoRow: View {
  let label: String
  let value: String
  
  var body: some View {
    HStack {
      Text(label)
        .foregroundColor(.secondary)
      Spacer()
      Text(value)
        .fontWeight(.medium)
    }
    .padding(12)
  }
}

#Preview {
  EmergencyCardView()
    .environmentObject(ProfileManager())
}
