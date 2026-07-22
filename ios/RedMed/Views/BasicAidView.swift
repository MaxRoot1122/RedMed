import SwiftUI

struct BasicAidView: View {
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    @State private var openPaneId: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Roadside Aid")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .tracking(-0.4)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 1, green: 0.45, blue: 0.55), AppTheme.accent, AppTheme.teal],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text("Call 911 first. Tap a pane — expand only what you need.")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 8) {
                            Text("tap to expand")
                                .font(.caption2.weight(.bold))
                                .textCase(.uppercase)
                                .foregroundStyle(AppTheme.accent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(AppTheme.accentSoft)
                                .clipShape(Capsule())
                            Text("911 first")
                                .font(.caption2.weight(.bold))
                                .textCase(.uppercase)
                                .foregroundStyle(AppTheme.muted)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.7))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 4)

                    LazyVGrid(columns: columns, spacing: 12) {
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
                            .gridCellColumns(openPaneId == pane.id ? 2 : 1)
                        }
                    }

                    Text("God of mercy, hold the injured in your care.\nGive strength to those who help, and wisdom to every choice made here.\nBring healing, comfort, and safe passage until help arrives.\nAmen.")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.muted)
                        .italic()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                        .padding(.horizontal, 8)
                }
                .padding(.horizontal, AppTheme.screenPad)
                .padding(.bottom, 24)
            }
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
}

private struct AidPaneCard: View {
    let pane: AidPane
    let isOpen: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack(alignment: isOpen ? .center : .top, spacing: 12) {
                    IconWell(
                        systemName: pane.icon,
                        tint: pane.critical ? Color.white : AppTheme.accent,
                        soft: pane.critical ? AppTheme.accent : AppTheme.accentSoft,
                        size: 44
                    )
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pane.title)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppTheme.ink)
                            .multilineTextAlignment(.leading)
                        if !isOpen {
                            Text(pane.blurb)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.muted)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.accent)
                        .rotationEffect(.degrees(isOpen ? 90 : 0))
                }
                .padding(14)
                .frame(maxWidth: .infinity, minHeight: isOpen ? 0 : 132, alignment: .topLeading)
            }
            .buttonStyle(.plain)

            if isOpen {
                VStack(spacing: 10) {
                    ForEach(pane.topics) { topic in
                        NavigationLink(value: topic) {
                            HStack {
                                Text(topic.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppTheme.ink)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: "chevron.right")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(AppTheme.muted)
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(AppTheme.line, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .appCard()
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .stroke(isOpen ? AppTheme.accent.opacity(0.28) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    BasicAidView()
}
