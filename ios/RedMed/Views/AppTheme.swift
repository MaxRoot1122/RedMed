import SwiftUI

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

    static let cardRadius: CGFloat = 24
    static let buttonRadius: CGFloat = 999
    static let chipRadius: CGFloat = 16
    static let screenPad: CGFloat = 20
}

// MARK: - Brand

struct BrandMark: View {
    enum Size { case hero, nav, compact }

    var size: Size = .nav
    var showTagline: Bool = false
    var titleOverride: String?

    private var wordmarkHeight: CGFloat {
        switch size {
        case .hero: return 46
        case .nav: return 38
        case .compact: return 32
        }
    }

    private var coverFrame: CGFloat {
        switch size {
        case .hero: return 52
        case .nav: return 44
        case .compact: return 36
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: size == .hero ? 8 : 4) {
            if let titleOverride, !titleOverride.isEmpty {
                HStack(spacing: 10) {
                    Image("BrandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: coverFrame, height: coverFrame)
                        .clipShape(RoundedRectangle(cornerRadius: coverFrame * 0.28, style: .continuous))
                        .shadow(color: AppTheme.accent.opacity(0.12), radius: 6, y: 3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(titleOverride)
                            .font(.system(size: size == .hero ? 28 : 17, weight: .bold, design: .rounded))
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
                    .frame(height: wordmarkHeight)
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
    var body: some View {
        ZStack {
            AppTheme.pageBg
            RadialGradient(
                colors: [AppTheme.accent.opacity(0.05), Color.clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 280
            )
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.45, blue: 0.55).opacity(0.04), Color.clear],
                center: .bottomTrailing,
                startRadius: 40,
                endRadius: 320
            )
        }
        .ignoresSafeArea()
    }
}

struct SectionEyebrow: View {
    let text: String
    var tint: Color = AppTheme.accent

    var body: some View {
        Text(text.uppercased())
            .font(.caption2.weight(.bold))
            .tracking(1.1)
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
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
    let systemName: String
    var tint: Color = AppTheme.accent
    var soft: Color = AppTheme.accentSoft
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(soft)
            Image(systemName: systemName)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(tint)
        }
        .frame(width: size, height: size)
    }
}

struct SoftStatusChip: View {
    let text: String
    var warning: Bool = false

    var body: some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(warning ? AppTheme.accent : AppTheme.muted)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(warning ? AppTheme.accentSoft : Color.white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.chipRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.chipRadius, style: .continuous)
                    .stroke(warning ? AppTheme.accent.opacity(0.2) : AppTheme.line, lineWidth: 1)
            )
    }
}

// MARK: - Buttons

struct PrimaryButtonStyle: ButtonStyle {
    var enabled: Bool = true
    var prominent: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(prominent ? .title3.weight(.bold) : .headline.weight(.bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, prominent ? 20 : 16)
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
            .shadow(color: enabled ? AppTheme.accent.opacity(0.18) : .clear, radius: 10, y: 4)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color.white.opacity(0.82))
            .foregroundStyle(AppTheme.ink)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AppTheme.line, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
            .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct InkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 16)
            .background(AppTheme.ink.opacity(configuration.isPressed ? 0.88 : 1))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.12), radius: 10, y: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

// MARK: - Cards

struct CardModifier: ViewModifier {
    var elevated: Bool = true

    func body(content: Content) -> some View {
        content
            .background(AppTheme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                    .stroke(AppTheme.line, lineWidth: 1)
            )
            .shadow(color: AppTheme.accent.opacity(elevated ? 0.04 : 0), radius: elevated ? 8 : 0, y: elevated ? 3 : 0)
    }
}

extension View {
    func appCard(elevated: Bool = true) -> some View {
        modifier(CardModifier(elevated: elevated))
    }

    func screenAtmosphere() -> some View {
        background { ScreenAtmosphere() }
    }
}
