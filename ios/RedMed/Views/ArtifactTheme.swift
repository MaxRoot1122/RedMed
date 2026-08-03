import SwiftUI
import CoreLocation

enum AppTab: Hashable {
    case myid, call911, emergency, aid, nfc
}

extension Color {
    static let redmedAccent = Color(red: 0.882, green: 0.114, blue: 0.282)
    static let redmedBg = Color(red: 1.000, green: 0.961, blue: 0.961)
    static let redmedDark = Color(red: 0.110, green: 0.098, blue: 0.086)
    static let redmedMuted = Color(red: 0.471, green: 0.443, blue: 0.424)
    static let redmedSurface = Color.white.opacity(0.92)
    static let redmedDivider = Color(red: 0.110, green: 0.098, blue: 0.086).opacity(0.07)
}

struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.redmedMuted)
            .kerning(0.6)
            .padding(.horizontal, 4)
            .padding(.bottom, 5)
    }
}

struct PillTag: View {
    let text: String
    let accent: Bool

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .bold))
            .kerning(0.8)
            .foregroundColor(accent ? .redmedAccent : .redmedMuted)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(accent ? Color.redmedAccent.opacity(0.1) : Color.white.opacity(0.7))
                    .overlay(Capsule().stroke(accent ? Color.clear : Color.redmedDivider, lineWidth: 1))
            )
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color(red: 1, green: 0.447, blue: 0.537), .redmedAccent],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color.redmedAccent.opacity(0.28), radius: 7, y: 4)
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon).font(.system(size: 14)) }
                Text(title).font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.redmedDark)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.82))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.redmedDivider, lineWidth: 1))
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        }
    }
}

struct ArtifactNavTitle: View {
    var body: some View {
        Image("BrandWordmark")
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(height: 18)
            .accessibilityLabel("RedMed")
    }
}

struct ArtifactBrandLockup: View {
    var height: CGFloat = 22

    var body: some View {
        Image("BrandWordmark")
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(height: height)
            .accessibilityLabel("RedMed")
    }
}

/// Artifact phone shell: one vertical scroll for header + body on every tab.
struct ArtifactTabShell<Content: View>: View {
    var showEdit: Bool = false
    var brandHeader: Bool = false
    var hideHeader: Bool = false
    var onEdit: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 0) {
                if !hideHeader { scrollHeader }
                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.visible, axes: .vertical)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.redmedBg)
    }

    @ViewBuilder
    private var scrollHeader: some View {
        HStack {
            if showEdit {
                ArtifactBrandLockup()
                Spacer()
                Button("Edit") { onEdit?() }
                    .font(.system(size: 17))
                    .foregroundColor(.redmedAccent)
                    .accessibilityLabel("Edit")
            } else if brandHeader {
                ArtifactBrandLockup()
                Spacer()
            } else {
                Spacer()
                ArtifactNavTitle()
                Spacer()
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(Color.white.opacity(0.9))
        .overlay(alignment: .bottom) {
            Divider().overlay(Color.redmedDark.opacity(0.08))
        }
    }
}

struct ArtifactCustomTabBar: View {
    @Binding var tab: AppTab

    var body: some View {
        VStack(spacing: 0) {
            Divider().overlay(Color(red: 0.9, green: 0.9, blue: 0.9))
            HStack(spacing: 0) {
                ArtifactTabBarItem(icon: "person.fill", label: "RedMed", isOn: tab == .myid) { tab = .myid }
                ArtifactTabBarItem(icon: "phone.circle.fill", label: "SOS", isOn: tab == .call911) { tab = .call911 }
                ArtifactTabBarItem(icon: "location.fill", label: "911", isOn: tab == .emergency) { tab = .emergency }
                ArtifactTabBarItem(icon: "cross.case.fill", label: "Aid", isOn: tab == .aid) { tab = .aid }
                ArtifactTabBarItem(icon: "wave.3.right", label: "NFC", isOn: tab == .nfc) { tab = .nfc }
            }
            .padding(.top, 1)

            Capsule()
                .fill(Color(red: 0.11, green: 0.098, blue: 0.086).opacity(0.18))
                .frame(width: 118, height: 3)
                .padding(.top, 2)
                .padding(.bottom, 4)
        }
        .background(Color.white)
    }
}

private struct ArtifactTabBarItem: View {
    let icon: String
    let label: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 1) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isOn ? .redmedAccent : Color(red: 0.372, green: 0.388, blue: 0.408))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isOn ? Color.redmedAccent.opacity(0.10) : Color.clear)
                    )
                Text(label)
                    .font(.system(size: 8, weight: isOn ? .semibold : .medium))
                    .foregroundColor(isOn ? .redmedAccent : Color(red: 0.372, green: 0.388, blue: 0.408))
                    .kerning(-0.1)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 2)
        }
        .buttonStyle(.plain)
    }
}

struct ArtifactGPSCard: View {
    let coordinate: CLLocationCoordinate2D?
    let accuracy: CLLocationAccuracy?
    let heading: CLLocationDirection?
    let altitude: CLLocationDistance?

    private var latStr: String {
        coordinate.map { String(format: "%.6f", $0.latitude) } ?? "–––"
    }

    private var lonStr: String {
        coordinate.map { String(format: "%.6f", $0.longitude) } ?? "–––"
    }

    private var dmsStr: String? {
        guard let coordinate else { return nil }
        return LocationFormatting.dms(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    private var accuracyText: String {
        guard let accuracy, accuracy > 0 else { return "––" }
        return "±\(Int(accuracy.rounded())) m"
    }

    private var headingAltitudeText: String? {
        LocationFormatting.headingAltitudeText(heading: heading, altitude: altitude)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text("LIVE GPS")
                .font(.system(size: 9, weight: .bold))
                .kerning(1.1)
                .foregroundColor(.redmedAccent)
                .padding(.horizontal, 9).padding(.vertical, 4)
                .background(Capsule().fill(Color.redmedAccent.opacity(0.1)))

            Text("\(latStr), \(lonStr)")
                .font(.system(size: 17, weight: .bold, design: .monospaced))
                .foregroundColor(.redmedDark)
                .multilineTextAlignment(.center)

            if let dmsStr {
                Text(dmsStr)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.redmedMuted)
                    .multilineTextAlignment(.center)
            }

            Text("Accuracy \(accuracyText)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.redmedMuted)

            if let headingAltitudeText {
                Text(headingAltitudeText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.redmedMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(Color.redmedSurface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.redmedDivider, lineWidth: 1))
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let numbered: Bool
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(.redmedAccent)
                    .frame(width: 28, height: 28)
                    .background(Color.redmedAccent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.redmedDark)
            }
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                    HStack(alignment: .top, spacing: 8) {
                        Text(numbered ? "\(i + 1)" : "→")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.redmedAccent)
                            .frame(width: 12)
                        Text(item)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.redmedDark)
                            .lineSpacing(3)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.redmedSurface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.redmedDivider, lineWidth: 1))
    }
}

struct NFCWriteOverlay: View {
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.redmedAccent.opacity(0.35), lineWidth: 1.5)
                        .frame(width: 104, height: 104)
                    Circle()
                        .fill(Color.redmedAccent.opacity(0.12))
                        .frame(width: 80, height: 80)
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 32))
                        .foregroundColor(.redmedAccent)
                }

                VStack(spacing: 8) {
                    Text("Hold to band")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("Bring the top of your iPhone close to the NFC bracelet")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 260)
                        .lineSpacing(3)
                }

                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32).padding(.vertical, 13)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
        }
    }
}
