import SwiftUI

struct BasicAidView: View {
    @State private var openPane: String?
    @State private var activeTopic: ArtifactAidTopic?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ArtifactTabShell {
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

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(artifactAidPanes) { pane in
                            let isOpen = openPane == pane.id
                            ArtifactPaneCard(pane: pane, isOpen: isOpen) { key in
                                if key == nil {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        openPane = isOpen ? nil : pane.id
                                    }
                                } else if let k = key, let topic = artifactAidTopics[k] {
                                    activeTopic = topic
                                }
                            }
                            .gridCellColumns(isOpen ? 2 : 1)
                        }
                    }

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
            ArtifactTopicDetailView(topic: topic)
        }
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
                        if !isOpen {
                            Text(pane.subtitle)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.redmedMuted)
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                    Image(systemName: isOpen ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.redmedAccent)
                }
                .padding(14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(minHeight: 100, alignment: .top)

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
        .background(Color.redmedSurface)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(isOpen ? Color.redmedAccent.opacity(0.28) : Color.redmedDivider, lineWidth: 1)
        )
    }
}

#Preview {
    BasicAidView()
}
