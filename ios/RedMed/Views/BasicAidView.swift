import SwiftUI

struct BasicAidView: View {
    @State private var openPane: String?
    @State private var activeTopic: ArtifactAidTopic?

    var body: some View {
        ArtifactTabShell(brandHeader: true) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Roadside Aid")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.redmedDark)
                Text("Call 911 first. Tap a pane — expand only what you need.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.redmedMuted)

                PrimaryButton(title: "Call 911") {
                    if let url = EmergencySummaryBuilder.call911URL {
                        UIApplication.shared.open(url)
                    }
                }

                HStack(spacing: 8) {
                    PillTag(text: "tap to expand", accent: true)
                    PillTag(text: "911 first", accent: false)
                }
                .padding(.bottom, 2)

                paneGrid

                Text("God of mercy, hold the injured in your care.\nGive strength to those who help, and wisdom to every choice made here.\nBring healing, comfort, and safe passage until help arrives.\nAmen.")
                    .font(.system(size: 10))
                    .italic()
                    .foregroundColor(Color(red: 0.659, green: 0.639, blue: 0.620))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
                    .padding(.bottom, 12)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
        .sheet(item: $activeTopic) { topic in
            NavigationStack {
                ArtifactTopicDetailView(topic: topic)
            }
        }
    }

    private var paneGrid: some View {
        VStack(spacing: 10) {
            ForEach(paneRows) { row in
                if row.panes.count == 1 {
                    paneCard(row.panes[0], isOpen: openPane == row.panes[0].id)
                } else {
                    HStack(alignment: .top, spacing: 10) {
                        paneCard(row.panes[0], isOpen: false)
                            .frame(maxWidth: .infinity)
                        paneCard(row.panes[1], isOpen: false)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .animation(nil, value: openPane)
    }

    private var paneRows: [AidPaneRow] {
        var rows: [AidPaneRow] = []
        var index = 0
        let panes = artifactAidPanes

        while index < panes.count {
            let pane = panes[index]
            if openPane == pane.id {
                rows.append(AidPaneRow(panes: [pane]))
                index += 1
            } else if index + 1 < panes.count, openPane != panes[index + 1].id {
                rows.append(AidPaneRow(panes: [panes[index], panes[index + 1]]))
                index += 2
            } else {
                rows.append(AidPaneRow(panes: [panes[index]]))
                index += 1
            }
        }
        return rows
    }

    private func paneCard(_ pane: ArtifactAidPane, isOpen: Bool) -> some View {
        ArtifactPaneCard(pane: pane, isOpen: isOpen) { key in
            if key == nil {
                openPane = isOpen ? nil : pane.id
            } else if let k = key, let topic = artifactAidTopics[k] {
                activeTopic = topic
            }
        }
    }
}

private struct AidPaneRow: Identifiable {
    let id: String
    let panes: [ArtifactAidPane]

    init(panes: [ArtifactAidPane]) {
        self.panes = panes
        self.id = panes.map(\.id).joined(separator: "|")
    }
}

private struct ArtifactPaneCard: View {
    let pane: ArtifactAidPane
    let isOpen: Bool
    let onTap: (String?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button { onTap(nil) } label: {
                HStack(alignment: .top, spacing: 10) {
                    Text(pane.emoji)
                        .font(.system(size: 22))
                        .frame(width: 40, height: 40)
                        .background(isOpen ? Color.redmedAccent : Color.redmedAccent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(pane.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.redmedDark)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        if !isOpen {
                            Text(pane.subtitle)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.redmedMuted)
                                .lineLimit(1)
                        }
                    }
                    Spacer(minLength: 0)
                    Image(systemName: isOpen ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.redmedAccent)
                }
                .padding(14)
                .frame(maxWidth: .infinity, minHeight: 100, alignment: .top)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isOpen {
                VStack(spacing: 7) {
                    ForEach(pane.topics, id: \.key) { topic in
                        Button { onTap(topic.key) } label: {
                            HStack {
                                Text(topic.label)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.redmedDark)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11))
                                    .foregroundColor(.redmedMuted)
                            }
                            .padding(.horizontal, 12).padding(.vertical, 10)
                            .background(Color.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.redmedDivider, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 14)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(isOpen ? Color.redmedAccent.opacity(0.28) : Color.redmedDivider, lineWidth: 1)
        )
    }
}

#Preview {
    BasicAidView()
        .safeAreaInset(edge: .bottom) {
            ArtifactCustomTabBar(tab: .constant(.aid))
        }
}
