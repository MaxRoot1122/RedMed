import CoreNFC

/// Reads a tag written by this app (or the web app's "Write tag" flow) back
/// into a MedicalProfile — entirely on-device. The NDEF payload is a URI
/// record whose "#d=" fragment already holds the full profile as base64;
/// ProfileLinkBuilder.decodeProfile decodes that locally, so this never
/// needs network access or the hosted page to be reachable, only physical
/// proximity to the tag.
final class NFCReader: NSObject, ObservableObject {
    @Published var statusMessage: String = ""
    @Published var isReading = false

    private var session: NFCNDEFReaderSession?
    private var onProfile: ((MedicalProfile, String) -> Void)?
    private var didDeliver = false

    func readTag(onProfile: @escaping (MedicalProfile, String) -> Void) {
        guard NFCNDEFReaderSession.readingAvailable else {
            statusMessage = "This device doesn't support NFC tag reading."
            return
        }
        self.onProfile = onProfile
        didDeliver = false
        isReading = true
        statusMessage = "Hold your iPhone near the NFC tag."

        let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session.alertMessage = "Hold your iPhone near the tag to read your medical ID."
        self.session = session
        session.begin()
    }

    private func deliverProfile(from urlString: String, session: NFCNDEFReaderSession) {
        guard !didDeliver else { return }
        guard let profile = ProfileLinkBuilder.decodeProfile(fromURLString: urlString) else {
            session.invalidate(errorMessage: "Couldn't read a RedMed card from this tag.")
            DispatchQueue.main.async { [weak self] in
                self?.isReading = false
                self?.statusMessage = "Couldn't read a RedMed card from this tag."
            }
            return
        }

        didDeliver = true
        session.alertMessage = "Tag read successfully."
        session.invalidate()
        DispatchQueue.main.async { [weak self] in
            self?.isReading = false
            self?.statusMessage = "Tag read successfully."
            self?.onProfile?(profile, urlString)
        }
    }
}

extension NFCReader: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        let payloads = messages.flatMap(\.records)
        guard let payload = payloads.first,
              let urlString = payload.wellKnownTypeURIPayload()?.absoluteString else {
            session.invalidate(errorMessage: "Couldn't read a RedMed card from this tag.")
            DispatchQueue.main.async { [weak self] in
                self?.isReading = false
                self?.statusMessage = "Couldn't read a RedMed card from this tag."
            }
            return
        }
        deliverProfile(from: urlString, session: session)
    }

    /// Newer iPhones and NTAG chips often surface tags here instead of didDetectNDEFs.
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "No tag found. Try again.")
            return
        }

        session.connect(to: tag) { [weak self] error in
            if let error {
                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                return
            }

            tag.readNDEF { message, error in
                if let error {
                    session.invalidate(errorMessage: "Read failed: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.isReading = false
                        self?.statusMessage = error.localizedDescription
                    }
                    return
                }

                guard let urlString = message?.records.first?.wellKnownTypeURIPayload()?.absoluteString else {
                    session.invalidate(errorMessage: "Couldn't read a RedMed card from this tag.")
                    DispatchQueue.main.async {
                        self?.isReading = false
                        self?.statusMessage = "Couldn't read a RedMed card from this tag."
                    }
                    return
                }

                self?.deliverProfile(from: urlString, session: session)
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isReading = false
            if let readerError = error as? NFCReaderError,
               readerError.code == .readerSessionInvalidationErrorUserCanceled {
                self.statusMessage = "Cancelled."
            }
        }
    }
}
