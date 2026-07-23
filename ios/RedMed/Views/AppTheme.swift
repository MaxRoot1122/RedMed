import SwiftUI

// MARK: - Layout (393×852 baseline — iPhone 15/16 class)

/// Scales spacing and control sizes from a 393×852 pt design baseline.
/// Read via `@Environment(\.layoutMetrics)` — never hardcode point values in views.
///
/// **Safe areas beat resolution.** Layout is constrained by system insets, not @2x/@3x
/// asset density. On Dynamic Island phones the usable top inset is ~**59 pt** (status bar +
/// island); the home indicator adds ~**34 pt** at the bottom. Let SwiftUI apply those via
/// default safe-area layout — do not bake 59/34 into view padding. Constants below are for
/// design review and Figma comps only.
///
/// **Mockups (not code):** two frames cover the iPhone range — **393×852** (standard) and
/// **440×956** (Pro Max). Code scales from the 393×852 baseline via `LayoutMetrics.scale`.
struct LayoutMetrics: Equatable {
    static let baselineWidth: CGFloat = 393
    static let baselineHeight: CGFloat = 852

    /// Figma / mockup — standard iPhone 15/16 class (matches code baseline).
    static let mockupFrameStandard = CGSize(width: 393, height: 852)
    /// Figma / mockup — large Pro Max class; spot-check only, no second code path.
    static let mockupFrameLarge = CGSize(width: 440, height: 956)

    /// Figma / design-review only — runtime uses `GeometryReader.safeAreaInsets`.
    static let referenceDynamicIslandTopInset: CGFloat = 59
    /// Figma / design-review only — tab bar adds its own height on top of this.
    static let referenceHomeIndicatorInset: CGFloat = 34

    let size: CGSize

    init(size: CGSize) {
        self.size = size
    }

    static let baseline = LayoutMetrics(
        size: CGSize(width: baselineWidth, height: baselineHeight)
    )

    /// Uniform scale — preserves proportions from SE through Pro Max.
    var scale: CGFloat {
        min(size.width / Self.baselineWidth, size.height / Self.baselineHeight)
    }

    func s(_ points: CGFloat) -> CGFloat { points * scale }

    var screenPad: CGFloat { s(20) }
    var spaceXS: CGFloat { s(4) }
    var spaceSM: CGFloat { s(8) }
    var spaceMD: CGFloat { s(12) }
    var spaceLG: CGFloat { s(16) }
    var spaceXL: CGFloat { s(20) }
    var space2XL: CGFloat { s(24) }
    /// Extra scroll breathing room *below* content — not a substitute for the 34 pt home indicator.
    var screenBottom: CGFloat { s(24) }
    var screenBottomLarge: CGFloat { s(32) }

    var cardRadius: CGFloat { s(24) }
    var chipRadius: CGFloat { s(16) }
    var innerRadius: CGFloat { s(14) }
    var iconWellRadius: CGFloat { s(14) }

    var iconWell: CGFloat { s(44) }
    var iconWellLarge: CGFloat { s(52) }
    var aidPaneMinHeight: CGFloat { s(132) }
    var cprPulse: CGFloat { s(56) }
    var nfcHeroInner: CGFloat { s(120) }
    var nfcHeroOuter: CGFloat { s(148) }
    var stepBadge: CGFloat { s(26) }
    var bulletDot: CGFloat { s(6) }
    var statusDot: CGFloat { s(7) }
    var topicIcon: CGFloat { s(22) }
    var cprResetMaxWidth: CGFloat { s(80) }

    func heroTitleFont() -> Font {
        .system(size: s(28), weight: .bold, design: .rounded)
    }

    func emergencyNameFont() -> Font {
        .system(size: s(32), weight: .bold, design: .rounded)
    }

    func navTitleFont() -> Font {
        .system(size: s(17), weight: .bold, design: .rounded)
    }

    func nfcGlyphFont() -> Font {
        .system(size: s(56), weight: .medium)
    }

    func brandWordmarkHeight(_ size: BrandMark.Size) -> CGFloat {
        switch size {
        case .hero: return s(46)
        case .nav: return s(38)
        case .compact: return s(32)
        }
    }

    func brandCoverFrame(_ size: BrandMark.Size) -> CGFloat {
        switch size {
        case .hero: return s(52)
        case .nav: return s(44)
        case .compact: return s(36)
        }
    }
}

private struct LayoutMetricsKey: EnvironmentKey {
    static let defaultValue = LayoutMetrics.baseline
}

extension EnvironmentValues {
    var layoutMetrics: LayoutMetrics {
        get { self[LayoutMetricsKey.self] }
        set { self[LayoutMetricsKey.self] = newValue }
    }
}

private struct LayoutMetricsScope: ViewModifier {
    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .frame(width: geo.size.width, height: geo.size.height)
                .environment(\.layoutMetrics, LayoutMetrics(size: geo.size))
        }
    }
}

// MARK: - Colors

/// RedMed tokens — medical rose, Gemini-like soft motion, dead-simple chrome.
enum AppTheme {
    static let accent = Color(red: 0.882, green: 0.114, blue: 0.282) // #e11d48
    static let accentSoft = Color(red: 0.882, green: 0.114, blue: 0.282).opacity(0.10)
    static let medical = accent
    static let medicalSoft = accentSoft
    static let teal = Color(red: 0.624, green: 0.071, blue: 0.224) // #9f1239 deep rose
    static let tealSoft = Color(red: 0.624, green: 0.071, blue: 0.224).opacity(0.08)
    static let ink = Color(red: 0.110, green: 0.098, blue: 0.090) // #1c1917
    static let muted = Color(red: 0.471, green: 0.443, blue: 0.424) // #78716c
    static let ok = accent
    static let pageBg = Color(red: 1.0, green: 0.969, blue: 0.969) // #fff7f7
    static let cardBg = Color.white.opacity(0.92)
    static let line = Color(red: 0.110, green: 0.098, blue: 0.090).opacity(0.08)
}

// MARK: - Brand

struct BrandMark: View {
    enum Size { case hero, nav, compact }

    @Environment(\.layoutMetrics) private var layout

    var size: Size = .nav
    var showTagline: Bool = false
    var titleOverride: String?

    var body: some View {
        let cover = layout.brandCoverFrame(size)
        VStack(alignment: .leading, spacing: size == .hero ? layout.spaceSM : layout.spaceXS) {
            if let titleOverride, !titleOverride.isEmpty {
                HStack(spacing: layout.s(10)) {
                    Image("BrandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: cover, height: cover)
                        .clipShape(RoundedRectangle(cornerRadius: cover * 0.28, style: .continuous))
                        .shadow(color: AppTheme.accent.opacity(0.12), radius: layout.s(6), y: layout.s(3))

                    VStack(alignment: .leading, spacing: layout.s(2)) {
                        Text(titleOverride)
                            .font(size == .hero ? layout.heroTitleFont() : layout.navTitleFont())
                            .foregroundStyle(AppTheme.ink)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                        Text("Linked bracelet")
                            .font(.caption2.weight(.bold))
                            .tracking(0.6)
                            .textCase(.uppercase)
                            .foregroundStyle(AppTheme.accent.opacity(0.85))
                    }
                }
            } else {
                Image("BrandWordmark")
                    .resizable()
                    .scaledToFit()
                    .frame(height: layout.brandWordmarkHeight(size))
                    .accessibilityLabel("RedMed")
            }

            if showTagline {
                Text("On your phone · on your bracelet · opens anywhere")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.muted)
            }
        }
    }
}

struct ScreenAtmosphere: View {
    @Environment(\.layoutMetrics) private var layout

    var body: some View {
        ZStack {
            AppTheme.pageBg
            RadialGradient(
                colors: [AppTheme.accent.opacity(0.05), Color.clear],
                center: .topLeading,
                startRadius: layout.s(20),
                endRadius: layout.s(280)
            )
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.45, blue: 0.55).opacity(0.04), Color.clear],
                center: .bottomTrailing,
                startRadius: layout.s(40),
                endRadius: layout.s(320)
            )
        }
        .ignoresSafeArea()
    }
}

struct SectionEyebrow: View {
    @Environment(\.layoutMetrics) private var layout

    let text: String
    var tint: Color = AppTheme.accent

    var body: some View {
        Text(text.uppercased())
            .font(.caption2.weight(.bold))
            .tracking(1.1)
            .foregroundStyle(tint)
            .padding(.horizontal, layout.s(10))
            .padding(.vertical, layout.s(5))
            .background(tint.opacity(0.1))
            .clipShape(Capsule())
    }
}

enum CopyHighlight {
    private static let phrases = [
        "Call 911", "call 911", "911 now", "911 first", "Press hard",
        "Don't stop", "Do NOT", "Note the time", "life-threatening",
        "Not breathing", "Can't breathe", "Keep warm", "Cool fast",
        "shivering stops", "hot dry skin"
    ]

    static func attributed(_ text: String, base: Color = AppTheme.ink) -> AttributedString {
        var result = AttributedString(text)
        result.foregroundColor = base
        result.font = .subheadline.weight(.medium)
        for phrase in phrases.sorted(by: { $0.count > $1.count }) {
            var search = result.startIndex
            while search < result.endIndex,
                  let range = result[search...].range(of: phrase, options: .caseInsensitive) {
                result[range].backgroundColor = AppTheme.accent.opacity(0.14)
                result[range].foregroundColor = AppTheme.teal
                result[range].font = .subheadline.weight(.bold)
                search = range.upperBound
            }
        }
        return result
    }
}

struct IconWell: View {
    @Environment(\.layoutMetrics) private var layout

    let systemName: String
    var tint: Color = AppTheme.accent
    var soft: Color = AppTheme.accentSoft
    var size: CGFloat?

    private var resolvedSize: CGFloat { size ?? layout.iconWell }

    var body: some View {
        let side = resolvedSize
        ZStack {
            RoundedRectangle(cornerRadius: layout.iconWellRadius, style: .continuous)
                .fill(soft)
            Image(systemName: systemName)
                .font(.system(size: side * 0.38, weight: .semibold))
                .foregroundStyle(tint)
        }
        .frame(width: side, height: side)
    }
}

struct SoftStatusChip: View {
    @Environment(\.layoutMetrics) private var layout

    let text: String
    var warning: Bool = false

    var body: some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(warning ? AppTheme.accent : AppTheme.muted)
            .multilineTextAlignment(.center)
            .padding(.horizontal, layout.s(14))
            .padding(.vertical, layout.spaceMD)
            .frame(maxWidth: .infinity)
            .background(warning ? AppTheme.accentSoft : Color.white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: layout.chipRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: layout.chipRadius, style: .continuous)
                    .stroke(warning ? AppTheme.accent.opacity(0.2) : AppTheme.line, lineWidth: 1)
            )
    }
}

// MARK: - Buttons

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.layoutMetrics) private var layout

    var enabled: Bool = true
    var prominent: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(prominent ? .title3.weight(.bold) : .headline.weight(.bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, prominent ? layout.s(20) : layout.spaceLG)
            .background(
                LinearGradient(
                    colors: enabled
                        ? [Color(red: 0.984, green: 0.443, blue: 0.522), AppTheme.accent]
                        : [Color.gray.opacity(0.55), Color.gray.opacity(0.45)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .shadow(color: enabled ? AppTheme.accent.opacity(0.18) : .clear, radius: layout.s(10), y: layout.s(4))
            .opacity(configuration.isPressed ? 0.92 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.layoutMetrics) private var layout

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, layout.s(15))
            .background(Color.white.opacity(0.82))
            .foregroundStyle(AppTheme.ink)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AppTheme.line, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: layout.s(8), y: layout.s(3))
            .shadow(color: Color.black.opacity(0.03), radius: layout.s(6), y: layout.s(2))
            .opacity(configuration.isPressed ? 0.88 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct InkButtonStyle: ButtonStyle {
    @Environment(\.layoutMetrics) private var layout

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, layout.s(18))
            .padding(.horizontal, layout.spaceLG)
            .background(AppTheme.ink.opacity(configuration.isPressed ? 0.88 : 1))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.12), radius: layout.s(10), y: layout.s(4))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

// MARK: - Cards

struct CardModifier: ViewModifier {
    @Environment(\.layoutMetrics) private var layout

    var elevated: Bool = true

    func body(content: Content) -> some View {
        content
            .background(AppTheme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: layout.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: layout.cardRadius, style: .continuous)
                    .stroke(AppTheme.line, lineWidth: 1)
            )
            .shadow(
                color: AppTheme.accent.opacity(elevated ? 0.04 : 0),
                radius: elevated ? layout.s(8) : 0,
                y: elevated ? layout.s(3) : 0
            )
    }
}

extension View {
    func appCard(elevated: Bool = true) -> some View {
        modifier(CardModifier(elevated: elevated))
    }

    func screenAtmosphere() -> some View {
        background { ScreenAtmosphere() }
    }

    /// Installs scaled layout metrics from the current container (393×852 baseline).
    func withLayoutMetrics() -> some View {
        modifier(LayoutMetricsScope())
    }
}
