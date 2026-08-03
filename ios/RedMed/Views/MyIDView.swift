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

    private var hasData: Bool { store.profile.hasOwnerData }

    var body: some View {
        ArtifactTabShell(showEdit: true, onEdit: beginEdit) {
            VStack(alignment: .leading, spacing: 0) {
                    if !hasData {
                        emptyPrompt
                    }

                    SectionLabel(text: "You").padding(.horizontal, 16).padding(.top, hasData ? 10 : 2)
                    cardGroup {
                        profileRow(label: "Name", value: store.profile.name)
                        Divider().padding(.leading, 16)
                        profileRow(label: "Birth date", value: birthDateDisplay)
                        Divider().padding(.leading, 16)
                        profileRow(label: "Blood type", value: store.profile.blood)
                    }

                    listSection(title: "Allergies", items: store.profile.allergies)
                    listSection(title: "Medications", items: store.profile.meds)
                    listSection(title: "Conditions", items: store.profile.conditions)

                    SectionLabel(text: "Contacts").padding(.horizontal, 16).padding(.top, 12)
                    cardGroup {
                        if filledContacts.isEmpty {
                            emptyRow()
                        } else {
                            ForEach(filledContacts) { contact in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(contact.name.isEmpty ? "Unnamed contact" : contact.name)
                                        .font(.system(size: 14, weight: .semibold)).foregroundColor(.redmedDark)
                                    Text(contactDetail(contact))
                                        .font(.system(size: 12, weight: .medium)).foregroundColor(.redmedMuted)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16).padding(.vertical, 11)
                                if contact.id != filledContacts.last?.id { Divider().padding(.leading, 16) }
                            }
                        }
                    }

                    HStack(spacing: 0) {
                        Button { tab = .nfc } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "wave.3.right.circle").font(.system(size: 18)).foregroundColor(.redmedAccent)
                                Text("Bracelet").font(.system(size: 12, weight: .semibold)).foregroundColor(.redmedAccent)
                            }.padding(.horizontal, 10).padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                        Divider().frame(height: 28)
                        Button { showHelp = true } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "questionmark.circle").font(.system(size: 18)).foregroundColor(.redmedMuted)
                                Text("How it works").font(.system(size: 12, weight: .semibold)).foregroundColor(.redmedMuted)
                            }.padding(.horizontal, 10).padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 14).padding(.bottom, 4)

                    Text("\"Control your fear. Control the moment. You have what it takes to save a life.\"")
                        .font(.system(size: 11)).italic().foregroundColor(.redmedDark)
                        .multilineTextAlignment(.center).lineSpacing(4)
                        .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 16)
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
        HStack(spacing: 0) {
            Text("Tap ").font(.system(size: 14, weight: .medium)).foregroundColor(.redmedMuted)
            Text("Edit").font(.system(size: 14, weight: .bold)).foregroundColor(.redmedAccent)
            Text(" to add your name and set up your bracelet.")
                .font(.system(size: 14, weight: .medium)).foregroundColor(.redmedMuted)
        }
        .padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 8)
    }

    private func contactDetail(_ contact: EmergencyContact) -> String {
        [contact.rel, contact.phone]
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    @ViewBuilder
    private func profileRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 14, weight: .medium)).foregroundColor(.redmedMuted)
            Spacer()
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(value.isEmpty ? Color.redmedMuted.opacity(0.4) : .redmedDark)
        }
        .padding(.horizontal, 16).padding(.vertical, 11)
    }

    @ViewBuilder
    private func emptyRow() -> some View {
        Text("—").font(.system(size: 14)).foregroundColor(Color.redmedMuted.opacity(0.4))
            .padding(.horizontal, 16).padding(.vertical, 11)
    }

    @ViewBuilder
    private func cardGroup<C: View>(@ViewBuilder content: () -> C) -> some View {
        VStack(spacing: 0) { content() }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.redmedSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.redmedDivider, lineWidth: 1))
            .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func listSection(title: String, items: [String]) -> some View {
        let visible = items
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        SectionLabel(text: title).padding(.horizontal, 16).padding(.top, 12)
        cardGroup {
            if visible.isEmpty { emptyRow() }
            else {
                ForEach(Array(visible.enumerated()), id: \.offset) { i, item in
                    Text(item).font(.system(size: 14)).foregroundColor(.redmedDark)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16).padding(.vertical, 11)
                    if i < visible.count - 1 { Divider().padding(.leading, 16) }
                }
            }
        }
    }
}

#Preview {
    MyIDView(tab: .constant(.myid))
        .environmentObject(ProfileStore())
        .environmentObject(BraceletLinkStore())
}
