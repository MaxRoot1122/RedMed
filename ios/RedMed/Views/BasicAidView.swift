import SwiftUI

/// Aid tab reads ~18% larger; spacing/grid unchanged — one knob for all copy.
private enum AidTabMetrics {
    static let textScale: CGFloat = 1.18

    static func t(_ layout: LayoutMetrics, _ points: CGFloat) -> CGFloat {
        layout.s(points * textScale)
    }

    static func tv(_ layout: LayoutMetrics, _ points: CGFloat) -> CGFloat {
        layout.sv(points * textScale)
    }

    static func paneMinHeight(_ layout: LayoutMetrics) -> CGFloat { tv(layout, 100) }
    static func iconSize(_ layout: LayoutMetrics) -> CGFloat { t(layout, 40) }
    static func cardPad(_ layout: LayoutMetrics) -> CGFloat { t(layout, 14) }

    static func heroTitle(_ layout: LayoutMetrics) -> Font {
        .system(size: t(layout, 25), weight: .bold, design: .rounded)
    }

    static func paneTitle(_ layout: LayoutMetrics) -> Font {
        .system(size: t(layout, 14), weight: .bold, design: .rounded)
    }

    static func paneBlurb(_ layout: LayoutMetrics) -> Font {
        .system(size: t(layout, 12), weight: .semibold, design: .rounded)
    }

    static func topicTitle(_ layout: LayoutMetrics) -> Font {
        .system(size: t(layout, 14), weight: .semibold, design: .rounded)
    }

    static func intro(_ layout: LayoutMetrics) -> Font {
        .system(size: t(layout, 14), weight: .medium, design: .rounded)
    }

    static func chip(_ layout: LayoutMetrics) -> Font {
        .system(size: t(layout, 11), weight: .bold, design: .rounded)
    }

    static func chevron(_ layout: LayoutMetrics) -> Font {
        .system(size: t(layout, 10), weight: .bold)
    }

    static func scripture(_ layout: LayoutMetrics) -> Font {
        .system(size: t(layout, 15), weight: .medium, design: .serif)
    }

    static func scriptureRef(_ layout: LayoutMetrics) -> Font {
        .system(size: t(layout, 12), weight: .semibold, design: .serif)
    }
}

struct BasicAidView: View {
    @Environment(\.layoutMetrics) private var layout

    @State private var openPaneId: String?
    @State private var activeTopic: FirstAidTopic?

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: layout.spaceMD),
            GridItem(.flexible(), spacing: layout.spaceMD)
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: layout.spaceXL) {
                    VStack(alignment: .leading, spacing: layout.spaceSM) {
                        Text("Roadside Aid")
                            .font(AidTabMetrics.heroTitle(layout))
                            .tracking(-0.4)
                            .foregroundStyle(AppTheme.titleGradient)
                        Text("Call 911 first. Tap a pane — expand only what you need.")
                            .font(AidTabMetrics.intro(layout))
                            .foregroundStyle(AppTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Call911Button()

                    HStack(spacing: layout.s(8)) {
                        DesignPillTag(text: "tap to expand", accent: true)
                        DesignPillTag(text: "911 first", accent: false)
                    }
                    .padding(.bottom, layout.s(2))

                    LazyVGrid(columns: columns, spacing: layout.spaceMD) {
                        ForEach(AidPaneLibrary.panes) { pane in
                            AidPaneCard(
                                pane: pane,
                                isOpen: openPaneId == pane.id,
                                activeTopic: $activeTopic,
                                onToggle: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                        openPaneId = openPaneId == pane.id ? nil : pane.id
                                    }
                                }
                            )
                            .gridCellColumns(openPaneId == pane.id ? 2 : 1)
                        }
                    }

                    aidScriptureFooter
                        .padding(.bottom, layout.screenBottom)
                }
                .padding(.horizontal, layout.screenPad)
                .padding(.top, layout.s(10))
                .reactiveScrollTrack()
            }
            .scrollIndicators(.visible, axes: .vertical)
            .background(AppTheme.pageBg)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Roadside Aid")
                        .font(.system(size: layout.s(17), weight: .semibold))
                        .foregroundStyle(AppTheme.ink)
                }
            }
            .sheet(item: $activeTopic) { topic in
                FirstAidDetailView(topic: topic)
                    .withLayoutMetrics()
            }
        }
    }

    private var aidScriptureFooter: some View {
        VStack(spacing: layout.s(6)) {
            Text(Self.joshuaVerse)
                .font(AidTabMetrics.scripture(layout))
                .italic()
                .foregroundStyle(AppTheme.muted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text("Joshua 1:9")
                .font(AidTabMetrics.scriptureRef(layout))
                .italic()
                .foregroundStyle(AppTheme.muted.opacity(0.85))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(Self.joshuaVerse) Joshua 1:9")
        .frame(maxWidth: .infinity)
        .padding(.top, layout.spaceSM + layout.s(31))
        .padding(.horizontal, layout.spaceSM)
    }

    private static let joshuaVerse =
        "Have I not commanded you? Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go."
}

private struct AidPaneCard: View {
    @Environment(\.layoutMetrics) private var layout

    let pane: AidPane
    let isOpen: Bool
    @Binding var activeTopic: FirstAidTopic?
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack(alignment: .top, spacing: layout.s(10)) {
                    Text(pane.emoji)
                        .font(.system(size: layout.s(22)))
                        .frame(width: AidTabMetrics.iconSize(layout), height: AidTabMetrics.iconSize(layout))
                        .background(isOpen ? AppTheme.accent : AppTheme.accentSoft)
                        .clipShape(RoundedRectangle(cornerRadius: layout.s(12), style: .continuous))

                    VStack(alignment: .leading, spacing: layout.s(3)) {
                        Text(pane.title)
                            .font(AidTabMetrics.paneTitle(layout))
                            .foregroundStyle(AppTheme.ink)
                            .multilineTextAlignment(.leading)
                        if !isOpen {
                            Text(pane.blurb)
                                .font(AidTabMetrics.paneBlurb(layout))
                                .foregroundStyle(AppTheme.muted)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: isOpen ? "chevron.down" : "chevron.right")
                        .font(AidTabMetrics.chevron(layout))
                        .foregroundStyle(AppTheme.accent)
                }
                .padding(AidTabMetrics.cardPad(layout))
                .frame(maxWidth: .infinity, minHeight: AidTabMetrics.paneMinHeight(layout), alignment: .topLeading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isOpen {
                VStack(spacing: layout.s(7)) {
                    ForEach(pane.topics) { topic in
                        Button {
                            activeTopic = topic
                        } label: {
                            HStack {
                                Text(topic.title)
                                    .font(AidTabMetrics.topicTitle(layout))
                                    .foregroundStyle(AppTheme.ink)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(AidTabMetrics.chevron(layout))
                                    .foregroundStyle(AppTheme.muted)
                            }
                            .padding(.horizontal, layout.s(12))
                            .padding(.vertical, layout.s(10))
                            .background(AppTheme.secondarySurface)
                            .clipShape(RoundedRectangle(cornerRadius: layout.s(12), style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: layout.s(12), style: .continuous)
                                    .stroke(AppTheme.line, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, layout.s(10))
                .padding(.bottom, layout.s(14))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(AppTheme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: layout.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: layout.cardRadius, style: .continuous)
                .stroke(isOpen ? AppTheme.accent.opacity(0.28) : AppTheme.line, lineWidth: 1)
        )
    }
}

#Preview {
    BasicAidView()
        .withLayoutMetrics()
}
