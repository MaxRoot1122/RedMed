import SwiftUI

struct EditProfileView: View {
    @Environment(\.layoutMetrics) private var layout
    @EnvironmentObject var store: ProfileStore
    @EnvironmentObject var link: BraceletLinkStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    /// When true, shown as the My ID tab (Save stays; no Cancel).
    var embedded: Bool = false

    /// When true, parent already ran device auth (sheet must not call LAContext itself).
    var initiallyUnlocked: Bool = false

    @State private var editUnlocked = false
    @State private var authInProgress = false

    @State private var draft: MedicalProfile = {
        var profile = MedicalProfile()
        while profile.contacts.count < 3 { profile.contacts.append(EmergencyContact()) }
        return profile
    }()
    @State private var medRows: [MedRow] = []
    @State private var showingClearConfirm = false
    @State private var showingAddAllergy = false
    @State private var showingAddMed = false
    @State private var showingAddCondition = false
    @State private var savedFlash = false
    @State private var showingBraceletSetup = false
    @State private var fullName = ""
    @StateObject private var braceletWriter = NFCWriter()

    private let bloodTypes = ["", "O-", "O+", "A-", "A+", "B-", "B+", "AB-", "AB+"]

    // Ordered roughly by U.S. outpatient prescription volume (ClinCalc DrugStats
    // Top 300) with emergency-relevant drugs — anticoagulants, insulins,
    // epinephrine, naloxone, steroids, opioids, antiseizure — kept prominent.
    static let commonMeds = [
        // Pain / anti-inflammatory
        "Acetaminophen (Tylenol)", "Ibuprofen (Advil/Motrin)", "Aspirin",
        "Naproxen (Aleve)", "Meloxicam", "Cyclobenzaprine (Flexeril)",
        // Cholesterol
        "Atorvastatin (Lipitor)", "Rosuvastatin (Crestor)", "Simvastatin", "Pravastatin",
        // Blood pressure / heart
        "Lisinopril", "Losartan", "Amlodipine", "Metoprolol", "Carvedilol",
        "Atenolol", "Hydrochlorothiazide", "Furosemide (Lasix)", "Spironolactone",
        "Diltiazem", "Clonidine", "Digoxin",
        // Diabetes
        "Metformin", "Glipizide", "Insulin glargine (Lantus)", "Insulin aspart (NovoLog)",
        "Insulin (regular)", "Semaglutide (Ozempic/Wegovy)", "Empagliflozin (Jardiance)",
        "Dulaglutide (Trulicity)",
        // Thyroid
        "Levothyroxine (Synthroid)",
        // Stomach / reflux
        "Omeprazole (Prilosec)", "Pantoprazole (Protonix)", "Famotidine (Pepcid)",
        // Respiratory
        "Albuterol inhaler", "Fluticasone (Flonase/Flovent)", "Montelukast (Singulair)",
        "Budesonide-formoterol (Symbicort)",
        // Mental health
        "Sertraline (Zoloft)", "Escitalopram (Lexapro)", "Fluoxetine (Prozac)",
        "Citalopram (Celexa)", "Duloxetine (Cymbalta)", "Venlafaxine (Effexor)",
        "Bupropion (Wellbutrin)", "Trazodone", "Mirtazapine (Remeron)",
        // Sedatives / benzodiazepines
        "Alprazolam (Xanax)", "Lorazepam (Ativan)", "Clonazepam (Klonopin)", "Diazepam (Valium)",
        // Nerve / seizure
        "Gabapentin (Neurontin)", "Pregabalin (Lyrica)", "Levetiracetam (Keppra)",
        "Lamotrigine (Lamictal)", "Topiramate (Topamax)", "Divalproex (Depakote)",
        "Levodopa-carbidopa (Sinemet)",
        // Blood thinners / antiplatelet
        "Warfarin (Coumadin)", "Apixaban (Eliquis)", "Rivaroxaban (Xarelto)",
        "Dabigatran (Pradaxa)", "Clopidogrel (Plavix)",
        // Steroids
        "Prednisone", "Methylprednisolone", "Hydrocortisone",
        // Antibiotics
        "Amoxicillin", "Amoxicillin-clavulanate (Augmentin)", "Azithromycin (Z-Pak)",
        "Cephalexin (Keflex)", "Doxycycline", "Ciprofloxacin",
        "Sulfamethoxazole-trimethoprim (Bactrim)", "Nitrofurantoin (Macrobid)",
        // Opioids / dependence
        "Tramadol (Ultram)", "Hydrocodone-acetaminophen (Norco)", "Oxycodone (OxyContin)",
        "Morphine", "Buprenorphine-naloxone (Suboxone)",
        // Emergency rescue
        "Epinephrine (EpiPen)", "Naloxone (Narcan)",
        // Other common
        "Tamsulosin (Flomax)", "Allopurinol", "Methotrexate",
        "Hydroxychloroquine (Plaquenil)", "Potassium chloride"
    ]

    // Grouped: drug allergies (penicillin/sulfa/NSAIDs are the most common),
    // the FDA's 9 major food allergens (sesame added 2023), then environmental.
    static let commonAllergens = [
        // Drugs
        "Penicillin", "Amoxicillin", "Cephalosporins", "Sulfa drugs (sulfonamides)",
        "Aspirin / NSAIDs", "Codeine / Opioids", "Morphine",
        "Local anesthetics (lidocaine)", "General anesthesia",
        "Iodine / Contrast dye", "Erythromycin / Macrolides", "Tetracycline",
        // Foods
        "Peanuts", "Tree nuts", "Shellfish", "Fish", "Eggs", "Milk / Dairy",
        "Soy", "Wheat / Gluten", "Sesame",
        // Environmental / other
        "Latex", "Bee / Wasp stings", "Pollen", "Dust mites", "Mold",
        "Pet dander", "Nickel", "Adhesive / Tape"
    ]

    // Most-prevalent U.S. chronic conditions (CDC) plus conditions and implants
    // that change emergency treatment (anticoagulation, dialysis, transplant,
    // adrenal insufficiency, immunocompromise, ICD/pacemaker).
    static let commonConditions = [
        // Cardiometabolic — most prevalent
        "Hypertension", "High cholesterol", "Diabetes (Type 1)", "Diabetes (Type 2)",
        "Obesity", "Heart disease", "Coronary artery disease", "Heart failure",
        "AFib", "Stroke history", "Thyroid disorder",
        // Implants / devices
        "Pacemaker", "ICD (implanted defibrillator)",
        // Respiratory
        "Asthma", "COPD", "Sleep apnea",
        // Neurological
        "Epilepsy / Seizure disorder", "Migraine", "Alzheimer's / Dementia",
        "Parkinson's disease", "Multiple sclerosis",
        // Kidney / liver
        "Kidney disease", "On dialysis", "Liver disease", "Hepatitis",
        // Immune / transplant / cancer
        "Cancer (active treatment)", "Organ transplant", "Immunocompromised",
        "HIV", "Adrenal insufficiency (Addison's)",
        // Autoimmune / blood
        "Lupus", "Rheumatoid arthritis", "Crohn's / IBD",
        "Sickle cell disease", "Hemophilia", "On blood thinners / anticoagulants",
        // Digestive / bone / eye
        "GERD / Acid reflux", "Osteoporosis", "Glaucoma", "Chronic pain",
        // Mental health
        "PTSD", "Anxiety disorder", "Depression", "Bipolar disorder", "Autism",
        // Other
        "Pregnancy", "Blind / Low vision", "Deaf / Hard of hearing",
        "Mobility impairment"
    ]

    /// Edits require device auth once this device has saved profile data.
    /// First-time setup stays open until the owner taps Save. Also stays
    /// open for the single foreground session that follows pairing a
    /// bracelet — never the pairing session itself — via
    /// `link.pendingPostPairingGrace` (armed/promoted/consumed in
    /// `ContentView` off app-wide scenePhase transitions).
    private var requiresEditAuth: Bool {
        store.profile.hasOwnerData && !link.pendingPostPairingGrace
    }

    private var editAuthAvailability: BiometricGate.Availability {
        BiometricGate.availability()
    }

    var body: some View {
        VStack(spacing: 0) {
            if embedded {
                embeddedNavBar
            } else {
                sheetNavBar
            }

            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if embedded {
                            embeddedHeader
                        }

                        if link.isLinked {
                            syncSection
                        }

                        EditSectionLabel(text: "You", isFirst: !embedded)
                        EditCard {
                            EditLabeledField(label: "Name", text: $fullName, placeholder: "Full name")
                            EditCardDivider(leadingInset: layout.s(106))
                            dobRow
                            EditCardDivider(leadingInset: layout.s(106))
                            bloodTypeRow
                            EditCardDivider(leadingInset: layout.s(106))
                            donorRow
                        }

                        listEditSection(title: "Allergies", items: $draft.allergies, addTitle: "Add allergy") {
                            showingAddAllergy = true
                        }

                        medicationsSection

                        listEditSection(title: "Conditions", items: $draft.conditions, addTitle: "Add condition") {
                            showingAddCondition = true
                        }

                        contactsSection

                        Button("Clear data", role: .destructive) {
                            showingClearConfirm = true
                        }
                        .font(.system(size: layout.s(15)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, layout.s(4))
                        .padding(.top, layout.s(22))

                        Text("On this device and your band only. Never uploaded.")
                            .font(.system(size: layout.s(12), weight: .medium))
                            .foregroundStyle(AppTheme.muted)
                            .padding(.horizontal, layout.s(4))
                            .padding(.top, layout.s(8))
                            .padding(.bottom, layout.s(48))
                    }
                    .padding(.top, layout.s(20))
                    .padding(.horizontal, layout.screenPad)
                }
                .background(ArtifactChrome.editSheetBg)
                .disabled(!editUnlocked)
                .blur(radius: editUnlocked ? 0 : 8)

                if requiresEditAuth && !editUnlocked && !authInProgress {
                    authGate
                }
            }
        }
        .onAppear {
            loadDraft()
            if initiallyUnlocked || !requiresEditAuth || editAuthAvailability == .none {
                editUnlocked = true
            } else if embedded {
                prepareEditAccess()
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                if link.pendingPostPairingGrace { link.consumePostPairingGrace() }
                if requiresEditAuth { editUnlocked = false }
            }
        }
        .onChange(of: braceletWriter.verified) { verified in
            guard verified,
                  let url = ProfileLinkBuilder.buildURL(profile: store.profile, baseURL: AppConfig.medicalCardBaseURL) else { return }
            link.link(name: link.deviceName, url: url.absoluteString)
        }
        .onChange(of: braceletWriter.success) { success in
            guard success, !braceletWriter.verified,
                  let url = ProfileLinkBuilder.buildURL(profile: store.profile, baseURL: AppConfig.medicalCardBaseURL) else { return }
            link.link(name: link.deviceName, url: url.absoluteString)
        }
        .sheet(isPresented: $showingBraceletSetup) {
            BraceletSetupView()
                .withLayoutMetrics()
        }
        .sheet(isPresented: $showingAddAllergy) {
            SearchAddSheet(
                title: "Add allergy",
                placeholder: "Search or type",
                suggestions: Self.commonAllergens,
                existing: draft.allergies
            ) { draft.allergies.append($0) }
        }
        .sheet(isPresented: $showingAddMed) {
            SearchAddSheet(
                title: "Add medication",
                placeholder: "Type 3+ letters to search",
                suggestions: Self.commonMeds,
                existing: medRows.map(\.name),
                minimumQueryLength: 3
            ) { medRows.append(MedRow(name: $0, dose: "")) }
        }
        .sheet(isPresented: $showingAddCondition) {
            SearchAddSheet(
                title: "Add condition",
                placeholder: "Search or type",
                suggestions: Self.commonConditions,
                existing: draft.conditions
            ) { draft.conditions.append($0) }
        }
        .confirmationDialog("Clear all data?", isPresented: $showingClearConfirm) {
            Button("Clear", role: .destructive) {
                Task { await clearAfterAuth() }
            }
        }
        .overlay {
            if braceletWriter.isWriting {
                NFCWriteOverlay { braceletWriter.cancel() }
            }
        }
    }

    private var sheetNavBar: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .font(.system(size: layout.s(17)))
                .foregroundStyle(AppTheme.accent)
            Spacer()
            Text("Edit Profile")
                .font(.system(size: layout.s(17), weight: .semibold))
                .foregroundStyle(AppTheme.ink)
            Spacer()
            Button(savedFlash ? "Saved" : "Save") { save() }
                .font(.system(size: layout.s(17), weight: .bold))
                .foregroundStyle(AppTheme.accent)
                .disabled(!editUnlocked)
        }
        .padding(.horizontal, layout.screenPad)
        .frame(height: layout.s(52))
        .background(ArtifactChrome.editSheetBg.opacity(0.95))
        .overlay(alignment: .bottom) {
            Divider().overlay(Color.black.opacity(0.12))
        }
    }

    private var embeddedNavBar: some View {
        HStack {
            Spacer()
            Button(savedFlash ? "Saved" : "Save") { save() }
                .font(.system(size: layout.s(17), weight: .bold))
                .foregroundStyle(AppTheme.accent)
                .disabled(!editUnlocked)
            Button {
                showingBraceletSetup = true
            } label: {
                BraceletToolbarButton(link: link)
            }
            .accessibilityLabel("Bracelet setup")
        }
        .padding(.horizontal, layout.screenPad)
        .frame(height: layout.s(44))
        .background(Color.white.opacity(0.9))
        .overlay(alignment: .bottom) {
            Divider().overlay(AppTheme.ink.opacity(0.08))
        }
    }

    @ViewBuilder
    private var embeddedHeader: some View {
        VStack(alignment: .leading, spacing: layout.s(10)) {
            if link.isLinked {
                BrandMark(size: .hero, titleOverride: link.deviceName)
            } else {
                BrandMark(size: .hero, showTagline: true)
                if fullName.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text("Add your name to unlock NFC write.")
                        .font(.system(size: layout.s(14), weight: .medium))
                        .foregroundStyle(AppTheme.muted)
                }
            }
        }
        .padding(.bottom, layout.s(16))
    }

    @ViewBuilder
    private var syncSection: some View {
        VStack(alignment: .leading, spacing: layout.s(10)) {
            BraceletSyncInstructions()
            if braceletWriter.isWriting || !braceletWriter.statusMessage.isEmpty {
                Text(braceletWriter.isWriting ? "Hold near bracelet…" : braceletWriter.statusMessage)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(braceletWriter.verified ? AppTheme.ok : AppTheme.ink)
            }
        }
        .padding(.bottom, layout.s(16))
    }

    @ViewBuilder
    private var dobRow: some View {
        HStack(spacing: 0) {
            Text("Birth date")
                .font(.system(size: layout.s(15), weight: .medium))
                .foregroundStyle(ArtifactChrome.editLabel)
                .frame(width: layout.s(90), alignment: .leading)
                .padding(.trailing, layout.s(12))
            DatePicker("", selection: dobBinding, displayedComponents: .date)
                .labelsHidden()
                .font(.system(size: layout.s(15)))
        }
        .padding(.horizontal, layout.screenPad)
        .padding(.vertical, layout.s(13))
    }

    @ViewBuilder
    private var bloodTypeRow: some View {
        HStack(spacing: 0) {
            Text("Blood type")
                .font(.system(size: layout.s(15), weight: .medium))
                .foregroundStyle(ArtifactChrome.editLabel)
                .frame(width: layout.s(90), alignment: .leading)
                .padding(.trailing, layout.s(12))
            Picker("", selection: $draft.blood) {
                ForEach(bloodTypes, id: \.self) { bt in
                    Text(bt.isEmpty ? "Unknown" : bt).tag(bt)
                }
            }
            .pickerStyle(.menu)
            .font(.system(size: layout.s(15)))
        }
        .padding(.horizontal, layout.screenPad)
        .padding(.vertical, layout.s(13))
    }

    @ViewBuilder
    private var donorRow: some View {
        HStack(spacing: 0) {
            Text("Organ donor")
                .font(.system(size: layout.s(15), weight: .medium))
                .foregroundStyle(ArtifactChrome.editLabel)
                .frame(width: layout.s(90), alignment: .leading)
                .padding(.trailing, layout.s(12))
            Toggle("", isOn: $draft.donor)
                .labelsHidden()
                .tint(AppTheme.accent)
        }
        .padding(.horizontal, layout.screenPad)
        .padding(.vertical, layout.s(13))
    }

    @ViewBuilder
    private func listEditSection(
        title: String,
        items: Binding<[String]>,
        addTitle: String,
        onAdd: @escaping () -> Void
    ) -> some View {
        EditSectionLabel(text: title)
        EditCard {
            ForEach(items.wrappedValue.indices, id: \.self) { index in
                HStack {
                    TextField(title, text: items[index])
                        .font(.system(size: layout.s(15)))
                        .foregroundStyle(AppTheme.ink)
                    Spacer()
                    EditRemoveButton {
                        withAnimation { _ = items.wrappedValue.remove(at: index) }
                    }
                }
                .padding(.horizontal, layout.screenPad)
                .padding(.vertical, layout.s(13))
                EditCardDivider()
            }
            EditAddRow(title: addTitle, action: onAdd)
        }
    }

    @ViewBuilder
    private var medicationsSection: some View {
        EditSectionLabel(text: "Medications")
        EditCard {
            ForEach($medRows) { $row in
                VStack(alignment: .leading, spacing: layout.s(4)) {
                    HStack {
                        TextField("Medication", text: $row.name)
                            .font(.system(size: layout.s(15), weight: .semibold))
                            .foregroundStyle(AppTheme.ink)
                        Spacer()
                        EditRemoveButton {
                            withAnimation { medRows.removeAll { $0.id == row.id } }
                        }
                    }
                    TextField("Dose", text: $row.dose)
                        .font(.system(size: layout.s(13)))
                        .foregroundStyle(AppTheme.muted)
                }
                .padding(.horizontal, layout.screenPad)
                .padding(.vertical, layout.s(13))
                EditCardDivider()
            }
            EditAddRow(title: "Add medication") { showingAddMed = true }
        }
    }

    @ViewBuilder
    private var contactsSection: some View {
        EditSectionLabel(text: "Emergency Contacts")
        EditCard {
            ForEach(draft.contacts.indices, id: \.self) { index in
                HStack(alignment: .top, spacing: layout.s(8)) {
                    VStack(alignment: .leading, spacing: layout.s(4)) {
                        TextField("Name", text: $draft.contacts[index].name)
                            .font(.system(size: layout.s(15), weight: .semibold))
                            .foregroundStyle(AppTheme.ink)
                        TextField("Relationship", text: $draft.contacts[index].rel)
                            .font(.system(size: layout.s(13)))
                            .foregroundStyle(AppTheme.muted)
                        TextField("Phone", text: $draft.contacts[index].phone)
                            .font(.system(size: layout.s(13)))
                            .foregroundStyle(AppTheme.muted)
                            .keyboardType(.phonePad)
                    }
                    Spacer()
                    EditRemoveButton {
                        withAnimation { draft.contacts[index] = EmergencyContact() }
                    }
                    .padding(.top, layout.s(4))
                }
                .padding(.horizontal, layout.screenPad)
                .padding(.vertical, layout.s(13))
                if index < draft.contacts.count - 1 {
                    EditCardDivider()
                }
            }
            EditAddRow(title: "Add contact") {
                if draft.contacts.count < 3 {
                    draft.contacts.append(EmergencyContact())
                }
            }
        }
    }

    @ViewBuilder
    private var authGate: some View {
        Color.black.opacity(0.15)
            .ignoresSafeArea()
        if authInProgress {
            ProgressView("Unlocking…")
                .font(.subheadline.weight(.semibold))
                .padding(layout.spaceLG)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: layout.s(16)))
        } else {
            VStack(spacing: layout.spaceMD) {
                Image(systemName: editAuthAvailability.iconSystemName)
                    .font(.system(size: layout.s(40)))
                    .foregroundStyle(AppTheme.accent)
                Text(editAuthAvailability.editGateTitle)
                    .font(.subheadline.weight(.semibold))
                    .multilineTextAlignment(.center)
                Button(editAuthAvailability.unlockButtonLabel) {
                    Task { await unlockForEdit() }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
            }
            .padding(layout.spaceLG)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: layout.s(16)))
            .withLayoutMetrics()
        }
    }

    private func prepareEditAccess() {
        guard requiresEditAuth else {
            editUnlocked = true
            return
        }
        guard editAuthAvailability != .none else {
            editUnlocked = true
            return
        }
        guard !editUnlocked, !authInProgress else { return }
        Task { await unlockForEdit() }
    }

    @MainActor
    private func unlockForEdit() async {
        guard requiresEditAuth, !editUnlocked else { return }
        authInProgress = true
        let ok = await BiometricGate.authenticate(reason: "Unlock to edit your medical ID")
        authInProgress = false
        if ok { editUnlocked = true }
    }

    @MainActor
    private func clearAfterAuth() async {
        let ok = await BiometricGate.authenticate(reason: "Confirm clearing your medical ID")
        guard ok else { return }
        store.clearAllData()
        link.clear()
        draft = store.profile
        fullName = ""
        while draft.contacts.count < 3 { draft.contacts.append(EmergencyContact()) }
        medRows = []
        editUnlocked = true
    }

    private func save() {
        guard editUnlocked else { return }
        draft.name = fullName.trimmingCharacters(in: .whitespaces)
        draft.meds = medRows.compactMap(Self.formatMed)
        draft.allergies = draft.allergies.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        draft.conditions = draft.conditions.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        draft.contacts = draft.contacts
            .map {
                var c = $0
                c.name = c.name.trimmingCharacters(in: .whitespaces)
                c.rel = c.rel.trimmingCharacters(in: .whitespaces)
                c.phone = c.phone.trimmingCharacters(in: .whitespaces)
                return c
            }
            .filter { !$0.name.isEmpty || !$0.rel.isEmpty || !$0.phone.isEmpty }
        draft.updated = ISO8601DateFormatter().string(from: Date())
        store.profile = draft
        loadDraft()
        syncBraceletIfLinked()
        if embedded {
            savedFlash = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { savedFlash = false }
        } else {
            dismiss()
        }
    }

    /// Passersby read `#d=` off the chip, not a server — re-write the band after each save.
    private func syncBraceletIfLinked() {
        guard link.isLinked, !store.profile.name.isEmpty else { return }
        guard let url = ProfileLinkBuilder.buildURL(profile: store.profile, baseURL: AppConfig.medicalCardBaseURL) else { return }
        braceletWriter.writeURL(url.absoluteString)
    }

    private func loadDraft() {
        draft = store.profile
        fullName = draft.name
        if draft.contacts.count < 3 {
            while draft.contacts.count < 3 { draft.contacts.append(EmergencyContact()) }
        }
        medRows = store.profile.meds.map(Self.parseMed)
        draft.allergies = draft.allergies.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        draft.conditions = draft.conditions.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    // Cached instead of built inside dobBinding's get/set — those closures
    // run on every DatePicker render/edit, and DateFormatter construction
    // is comparatively expensive to repeat that often.
    private static let dobFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private var dobBinding: Binding<Date> {
        Binding(
            get: {
                Self.dobFormatter.date(from: draft.dob) ?? Date(timeIntervalSince1970: 0)
            },
            set: {
                draft.dob = Self.dobFormatter.string(from: $0)
            }
        )
    }

    /// Matches `joinProfileName` / `splitProfileName` encoding for NFC `#d=` parity.
    private static func joinProfileName(first: String, last: String) -> String {
        [first, last]
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private static func splitProfileName(_ full: String) -> (first: String, last: String) {
        let trimmed = full.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return ("", "") }
        guard let space = trimmed.firstIndex(of: " ") else { return (trimmed, "") }
        return (
            String(trimmed[..<space]).trimmingCharacters(in: .whitespaces),
            String(trimmed[trimmed.index(after: space)...]).trimmingCharacters(in: .whitespaces)
        )
    }

    private static func parseMed(_ raw: String) -> MedRow {
        if let range = raw.range(of: " — ") {
            return MedRow(name: String(raw[raw.startIndex..<range.lowerBound]),
                           dose: String(raw[range.upperBound...]))
        }
        return MedRow(name: raw, dose: "")
    }

    private static func formatMed(_ row: MedRow) -> String? {
        let name = row.name.trimmingCharacters(in: .whitespaces)
        let dose = row.dose.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return nil }
        return dose.isEmpty ? name : "\(name) — \(dose)"
    }
}

private struct MedRow: Identifiable {
    let id = UUID()
    var name: String = ""
    var dose: String = ""
}

private struct SearchAddSheet: View {
    let title: String
    let placeholder: String
    let suggestions: [String]
    let existing: [String]
    var minimumQueryLength: Int = 0
    let onAdd: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var filtered: [String] {
        let q = trimmedQuery
        let base = suggestions.filter { !existing.contains($0) }
        guard q.count >= minimumQueryLength else { return [] }
        return base.filter { $0.localizedCaseInsensitiveContains(q) }
    }

    private var canAddCustom: Bool {
        let q = trimmedQuery
        return !q.isEmpty && !existing.contains(where: { $0.caseInsensitiveCompare(q) == .orderedSame })
    }

    var body: some View {
        NavigationStack {
            List {
                if minimumQueryLength > 0, trimmedQuery.count > 0, trimmedQuery.count < minimumQueryLength {
                    Text("Type at least \(minimumQueryLength) characters to search.")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(AppTheme.muted)
                }
                if canAddCustom {
                    Button("Add \"\(trimmedQuery)\"") {
                        add(query)
                    }
                }
                ForEach(filtered, id: \.self) { item in
                    Button(item) { add(item) }
                }
            }
            .searchable(text: $query, prompt: placeholder)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .tint(AppTheme.accent)
        }
    }

    private func add(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onAdd(trimmed)
        dismiss()
    }
}

#Preview {
    EditProfileView(embedded: true)
        .environmentObject(ProfileStore())
        .environmentObject(BraceletLinkStore())
}
