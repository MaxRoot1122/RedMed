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

                        Call911Button()

                        HStack(spacing: layout.spaceSM) {
                            Text("tap to expand")
                                .font(AidTabMetrics.chip(layout))
                                .textCase(.uppercase)
                                .foregroundStyle(AppTheme.accent)
                                .padding(.horizontal, layout.s(10))
                                .padding(.vertical, layout.s(5))
                                .background(AppTheme.accentSoft)
                                .clipShape(Capsule())
                            Text("911 first")
                                .font(AidTabMetrics.chip(layout))
                                .textCase(.uppercase)
                                .foregroundStyle(AppTheme.muted)
                                .padding(.horizontal, layout.s(10))
                                .padding(.vertical, layout.s(5))
                                .background(AppTheme.chipBg)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.top, layout.pageTopInset)

                    LazyVGrid(columns: columns, spacing: layout.spaceMD) {
                        ForEach(AidPaneLibrary.panes) { pane in
                            AidPaneCard(
                                pane: pane,
                                isOpen: openPaneId == pane.id,
                                onToggle: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                        openPaneId = openPaneId == pane.id ? nil : pane.id
                                    }
                                }
                            )
                        }
                    }

                    aidScriptureFooter
                }
                .padding(.horizontal, layout.screenPad)
                .padding(.bottom, layout.screenBottom)
                .reactiveScrollTrack()
            }
            .reactiveScrollChrome()
            .scrollIndicators(.visible, axes: .vertical)
            .screenAtmosphere()
            .navigationTitle("Aid")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    BrandMark(size: .nav)
                }
            }
            .navigationDestination(for: FirstAidTopic.self) { topic in
                FirstAidDetailView(topic: topic)
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
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack(alignment: isOpen ? .center : .top, spacing: layout.spaceMD) {
                    IconWell(
                        systemName: pane.icon,
                        tint: pane.critical ? Color.white : AppTheme.accent,
                        soft: pane.critical ? AppTheme.accent : AppTheme.accentSoft,
                        size: AidTabMetrics.iconSize(layout)
                    )
                    VStack(alignment: .leading, spacing: layout.spaceXS) {
                        Text(pane.title)
                            .font(AidTabMetrics.paneTitle(layout))
                            .foregroundStyle(AppTheme.ink)
                            .multilineTextAlignment(.leading)
                        if !isOpen {
                            Text(pane.blurb)
                                .font(AidTabMetrics.paneBlurb(layout))
                                .foregroundStyle(AppTheme.muted)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.right")
                        .font(AidTabMetrics.chevron(layout))
                        .foregroundStyle(AppTheme.accent)
                        .rotationEffect(.degrees(isOpen ? 90 : 0))
                        .animation(.spring(response: 0.35, dampingFraction: 0.86), value: isOpen)
                }
                .padding(AidTabMetrics.cardPad(layout))
                .frame(maxWidth: .infinity, minHeight: AidTabMetrics.paneMinHeight(layout), alignment: isOpen ? .center : .topLeading)
            }
            .buttonStyle(.plain)

            if isOpen {
                VStack(spacing: layout.s(10)) {
                    ForEach(pane.topics) { topic in
                        NavigationLink(value: topic) {
                            HStack {
                                Text(topic.title)
                                    .font(AidTabMetrics.topicTitle(layout))
                                    .foregroundStyle(AppTheme.ink)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: "chevron.right")
                                    .font(AidTabMetrics.chevron(layout))
                                    .foregroundStyle(AppTheme.muted)
                            }
                            .padding(layout.spaceLG)
                            .background(AppTheme.secondarySurface)
                            .clipShape(RoundedRectangle(cornerRadius: layout.innerRadius, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: layout.innerRadius, style: .continuous)
                                    .stroke(AppTheme.line, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, layout.spaceMD)
                .padding(.bottom, layout.s(14))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .appCard()
        .overlay(
            RoundedRectangle(cornerRadius: layout.cardRadius, style: .continuous)
                .stroke(isOpen ? AppTheme.accent.opacity(0.28) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    BasicAidView()
        .withLayoutMetrics()
}
