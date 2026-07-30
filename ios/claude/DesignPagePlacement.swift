import Foundation

/// Maps `DesignPageCopy` snippets to the app surfaces that display them.
enum DesignPagePlacement {

    // Page 1 — My ID header / BrandMark tagline (iPhone owner product)
    static let brandTagline = DesignPageCopy.Page1.tagline
    static let brandLead = DesignPageCopy.Page1.lead

    // Page 3 — NFC tab, bracelet setup, empty My ID (Apple setup path)
    static let nfcHeroTitle = "Two screens. One tap."
    static let nfcHeroSubtitle = "iPhone only for setup. Fill My ID, write the band once — CoreNFC, Face ID, done."
    static let braceletHeroTitle = DesignPageCopy.Page3.title
    static let braceletHeroSubtitle = DesignPageCopy.Page3.lead + " Program the chip once on iPhone; strangers never need RedMed."
    static let myIDEmptyPrompt = "Tap Edit to fill your details, then program the band from the NFC tab — iPhone setup, any-phone read."

    // Page 4 — Android reader lane (minimal)
    static let androidReaderNote = DesignPageCopy.Page4.androidReaderNote

    // Page 5 — first-launch consent
    static let consentRegulatory = DesignPageCopy.Page5.consentSummary
}
