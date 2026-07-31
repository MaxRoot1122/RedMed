import Foundation
import CoreNFC

class NFCManager: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
  @Published var lastData: String?
  @Published var alertMessage = ""
  @Published var showAlert = false
  
  var nfcSession: NFCNDEFReaderSession?
  
  func startNFCReading() {
    nfcSession = NFCNDEFReaderSession(delegate: self, queue: .main, invalidateAfterFirstRead: true)
    nfcSession?.begin()
  }
  
  // MARK: - NFCNDEFReaderSessionDelegate
  
  func readerSession(_ session: NFCNDEFReaderSession, didDetect messages: [NFCNDEFMessage]) {
    DispatchQueue.main.async {
      if let message = messages.first,
         let record = message.records.first,
         let payload = String(data: record.payload, encoding: .utf8) {
        self.lastData = payload
        self.alertMessage = "NFC detected: \(payload)"
      } else {
        self.alertMessage = "NFC tag detected but no data found."
      }
      self.showAlert = true
    }
  }
  
  func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
    DispatchQueue.main.async {
      self.alertMessage = "NFC reading failed: \(error.localizedDescription)"
      self.showAlert = true
    }
  }
}
