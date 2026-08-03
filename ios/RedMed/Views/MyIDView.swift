import SwiftUI

struct MyIDView: View {
    @EnvironmentObject var store: ProfileStore
    @EnvironmentObject var link: BraceletLinkStore
    @Environment(\.scenePhase) private var scenePhase
    @Binding var tab: AppTab

    @State private var showEdit = false
    @State private var showHelp = false
    @AppStorage("redMedUseConsent") private var useConsentAccepted = false
    @State private var showConsent = false

    private static let dobFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        return f
    }()

    private var birthDateDisplay: String {
        guard !store.profile.dob.isEmpty,
              let date = Self.dobFormatter.date(from: store.profile.dob) else { return "" }
        return Self.displayFormatter.string(from: date)
    }

    private var filledContacts: [EmergencyContact] {
        store.profile.contacts.filter {
            !$0.name.trimmingCharacters(in: .whitespaces).isEmpty
                || !$0.phone.trimmingCharacters(in: .whitespaces).isEmpty
                || !$0.rel.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    private var isEmpty: Bool {
        store.profile.name.trimmingCharacters(in: .whitespaces).isEmpty
            && store.profile.dob.isEmpty
            && store.profile.blood.isEmpty
            && store.profile.allergies.isEmpty
            && store.profile.meds.isEmpty
            && store.profile.conditions.isEmpty
            && filledContacts.isEmpty
    }

    var body: some View {
        ArtifactTabShell(showEdit: true, onEdit: beginEdit) {
            VStack(alignment: .leading, spacing: 0) {
                if isEmpty {
                    emptyPrompt
                }

                sectionHeader("You")
                    .padding(.top, isEmpty ? 4 : 10)

                profileCard {
                    profileRow(label: "Name", value: store.profile.name)
                    cardDivider
                    profileRow(label: "Birth date", value: birthDateDisplay)
                    cardDivider
                    profileRow(label: "Blood type", value: store.profile.blood)
                }

                listSection(title: "Allergies", items: store.profile.allergies)
                listSection(title: "Medications", items: store.profile.meds)
                listSection(title: "Conditions", items: store.profile.conditions)

                sectionHeader("Contacts")
                profileCard {
                    if filledContacts.isEmpty {
                        placeholderRow
                    } else {
                        ForEach(Array(filledContacts.enumerated()), id: \.element.id) { index, contact in
                            if index > 0 { cardDivider }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(contact.name.isEmpty ? "Unnamed contact" : contact.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.redmedDark)
                                if !contactDetail(contact).isEmpty {
                                    Text(contactDetail(contact))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.redmedMuted)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 11)
                        }
                    }
                }

                quickActions
                footerQuote
            }
            .padding(.bottom, 8)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background { showEdit = false }
        }
        .sheet(isPresented: $showEdit) {
            EditProfileView()
                .environmentObject(store)
                .environmentObject(link)
        }
        .sheet(isPresented: $showHelp) {
            HelpMenuView()
        }
        .fullScreenCover(isPresented: $showConsent) {
            UseConsentView {
                useConsentAccepted = true
                showConsent = false
                showEdit = true
            }
        }
    }

    private func beginEdit() {
        if useConsentAccepted {
            showEdit = true
        } else {
            showConsent = true
        }
    }

    private var emptyPrompt: some View {
        Group {
            Text("Tap ")
                .foregroundColor(.redmedMuted)
            + Text("Edit")
                .fontWeight(.bold)
                .foregroundColor(.redmedAccent)
            + Text(" to add your name and set up your bracelet.")
                .foregroundColor(.redmedMuted)
        }
        .font(.system(size: 14, weight: .medium))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    private var quickActions: some View {
        HStack(spacing: 0) {
            Button { tab = .nfc } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.redmedAccent)
                    Text("Bracelet")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.redmedAccent)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)

            Rectangle()
                .fill(Color.redmedDivider)
                .frame(width: 1, height: 28)

            Button { showHelp = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.redmedMuted)
                    Text("How it works")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.redmedMuted)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }

    private var footerQuote: some View {
        Text("\"Control your fear. Control the moment. You have what it takes to save a life.\"")
            .font(.system(size: 11))
            .italic()
            .foregroundColor(.redmedDark)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 16)
    }

    private func contactDetail(_ contact: EmergencyContact) -> String {
        [contact.rel, contact.phone]
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    @ViewBuilder
    private func sectionHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.redmedMuted)
            .kerning(0.6)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 5)
    }

    @ViewBuilder
    private func profileRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.redmedMuted)
            Spacer(minLength: 12)
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(value.isEmpty ? Color.redmedMuted.opacity(0.45) : .redmedDark)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }

    private var placeholderRow: some View {
        Text("—")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color.redmedMuted.opacity(0.45))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
    }

    private var cardDivider: some View {
        Divider().padding(.leading, 16)
    }

    @ViewBuilder
    private func profileCard<C: View>(@ViewBuilder content: () -> C) -> some View {
        VStack(spacing: 0) { content() }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.redmedDivider, lineWidth: 1))
            .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func listSection(title: String, items: [String]) -> some View {
        let visible = items
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        sectionHeader(title)
        profileCard {
            if visible.isEmpty {
                placeholderRow
            } else {
                ForEach(Array(visible.enumerated()), id: \.offset) { index, item in
                    if index > 0 { cardDivider }
                    Text(item)
                        .font(.system(size: 14))
                        .foregroundColor(.redmedDark)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 11)
                }
            }
        }
    }
}

#Preview("Empty") {
    MyIDView(tab: .constant(.myid))
        .environmentObject(ProfileStore())
        .environmentObject(BraceletLinkStore())
        .safeAreaInset(edge: .bottom) {
            ArtifactCustomTabBar(tab: .constant(.myid))
        }
}

#Preview("Filled") {
    let store = ProfileStore()
    store.profile = MedicalProfile(
        name: "Alex Rivera",
        dob: "1990-05-15",
        blood: "O+",
        allergies: ["Penicillin"],
        meds: ["Metformin"],
        conditions: ["Diabetes (Type 2)"],
        contacts: [EmergencyContact(name: "Jordan", rel: "Spouse", phone: "555-0100")]
    )
    return MyIDView(tab: .constant(.myid))
        .environmentObject(store)
        .environmentObject(BraceletLinkStore())
        .safeAreaInset(edge: .bottom) {
            ArtifactCustomTabBar(tab: .constant(.myid))
        }
}
