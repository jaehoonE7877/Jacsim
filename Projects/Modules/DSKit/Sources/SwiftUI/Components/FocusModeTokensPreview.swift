import SwiftUI
import UIKit

private struct FocusModeTokensPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .jsXL) {
                paletteSection
                wallpaperSection
                typeSection
                spacingSection
            }
            .padding(.jsXL)
        }
        .background(Color.backgroundNormal)
        .modifier(FocusModeFontRegistrationLogModifier())
        .accessibilityLabel("focus mode design token preview")
    }

    private var paletteSection: some View {
        VStack(alignment: .leading, spacing: .jsMD) {
            Text("Color")
                .font(.jsSerifTitle)
                .foregroundStyle(Color.labelStrong)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: .jsSM)], spacing: .jsSM) {
                ForEach(colorTokens) { token in
                    VStack(alignment: .leading, spacing: .jsXS) {
                        RoundedRectangle(cornerRadius: .jsCornerMedium)
                            .fill(token.color)
                            .frame(height: 52)
                            .overlay {
                                RoundedRectangle(cornerRadius: .jsCornerMedium)
                                    .stroke(Color.labelAssistive, lineWidth: 1)
                            }
                            .accessibilityLabel("\(token.name) swatch")
                        Text(token.name)
                            .font(.jsLabelSmall)
                            .foregroundStyle(Color.labelNeutral)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                }
            }
        }
    }

    private var wallpaperSection: some View {
        VStack(alignment: .leading, spacing: .jsMD) {
            Text("Wallpaper")
                .font(.jsSerifTitle)
                .foregroundStyle(Color.labelStrong)
            VStack(spacing: .jsSM) {
                wallpaperTile(name: "Morning", gradient: LinearGradient.wallpaperMorning)
                wallpaperTile(name: "Forest", gradient: LinearGradient.wallpaperForest)
                wallpaperTile(name: "Dusk", gradient: LinearGradient.wallpaperDusk)
            }
        }
    }

    private var typeSection: some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            Text("Typography")
                .font(.jsSerifTitle)
                .foregroundStyle(Color.labelStrong)
            Text("작게 시작해요")
                .font(.jsSerifHero)
                .foregroundStyle(Color.labelNormal)
                .accessibilityLabel("serif hero token")
            Text("5월의 기록")
                .font(.jsSerifDisplay)
                .foregroundStyle(Color.labelNormal)
                .accessibilityLabel("serif display token")
            Text("오늘 해야 할 일은 오늘만큼만.")
                .font(.jsSerifTitle)
                .foregroundStyle(Color.labelNormal)
                .accessibilityLabel("serif title token")
            Text("꾸준함은 작게 반복될 때 남아요.")
                .font(.jsSerifQuote)
                .foregroundStyle(Color.labelNeutral)
                .accessibilityLabel("serif quote token")
            Text("Serif helper 42 / italic")
                .font(.jsSerif(42, italic: true))
                .foregroundStyle(Color.forestAccent)
                .accessibilityLabel("serif helper italic token")
            Text("D-14")
                .font(.jsMonoLarge)
                .foregroundStyle(Color.forestAccent)
                .accessibilityLabel("mono large token")
            Text("07:30")
                .font(.jsMonoMedium)
                .foregroundStyle(Color.labelNormal)
                .accessibilityLabel("mono medium token")
            Text("42%")
                .font(.jsMonoSmall)
                .foregroundStyle(Color.labelNeutral)
                .accessibilityLabel("mono small token")
        }
    }

    private var spacingSection: some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            Text("Spacing")
                .font(.jsSerifTitle)
                .foregroundStyle(Color.labelStrong)
            HStack(spacing: .jsTabBarMargin) {
                spacingBlock("micro", width: .jsMicro)
                spacingBlock("xs", width: .jsXS)
                spacingBlock("sm", width: .jsSM)
                spacingBlock("md", width: .jsMD)
                spacingBlock("tab", width: .jsTabBarMargin)
            }
            .accessibilityLabel("spacing token preview")
        }
    }

    private func wallpaperTile(name: String, gradient: LinearGradient) -> some View {
        RoundedRectangle(cornerRadius: .jsCornerLarge)
            .fill(gradient)
            .frame(height: 92)
            .overlay(alignment: .bottomLeading) {
                Text(name)
                    .font(.jsMonoSmall)
                    .foregroundStyle(Color.labelStrong)
                    .padding(.jsSM)
            }
            .accessibilityLabel("\(name) wallpaper gradient")
    }

    private func spacingBlock(_ label: String, width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: .jsXS) {
            RoundedRectangle(cornerRadius: .jsCornerSmall)
                .fill(Color.primaryNormal)
                .frame(width: max(width, .jsMicro), height: .jsSM)
            Text(label)
                .font(.jsLabelSmall)
                .foregroundStyle(Color.labelNeutral)
        }
    }

    private var colorTokens: [FocusModeColorToken] {
        [
            .init(name: "primaryNormal", color: .primaryNormal),
            .init(name: "primaryStrong", color: .primaryStrong),
            .init(name: "primaryHeavy", color: .primaryHeavy),
            .init(name: "labelNormal", color: .labelNormal),
            .init(name: "labelStrong", color: .labelStrong),
            .init(name: "labelNeutral", color: .labelNeutral),
            .init(name: "labelAlternative", color: .labelAlternative),
            .init(name: "labelAssistive", color: .labelAssistive),
            .init(name: "labelDisable", color: .labelDisable),
            .init(name: "backgroundNormal", color: .backgroundNormal),
            .init(name: "backgroundStrong", color: .backgroundStrong),
            .init(name: "backgroundAlternative", color: .backgroundAlternative),
            .init(name: "positive", color: .positive),
            .init(name: "cautionary", color: .cautionary),
            .init(name: "destructive", color: .destructive),
            .init(name: "streakActive", color: .streakActive),
            .init(name: "streakCompleted", color: .streakCompleted),
            .init(name: "streakFrozen", color: .streakFrozen),
            .init(name: "progressLow", color: .progressLow),
            .init(name: "progressMedium", color: .progressMedium),
            .init(name: "progressHigh", color: .progressHigh),
            .init(name: "achievement", color: .achievement),
            .init(name: "surfaceElevated", color: .surfaceElevated),
            .init(name: "surfaceOverlay", color: .surfaceOverlay),
            .init(name: "surfaceSelected", color: .surfaceSelected),
            .init(name: "forestAccent", color: .forestAccent),
            .init(name: "wallpaperMorning", color: .wallpaperMorning),
            .init(name: "wallpaperMorningTop", color: .wallpaperMorningTop),
            .init(name: "wallpaperMorningBottom", color: .wallpaperMorningBottom),
            .init(name: "wallpaperForest", color: .wallpaperForest),
            .init(name: "wallpaperForestTop", color: .wallpaperForestTop),
            .init(name: "wallpaperForestBottom", color: .wallpaperForestBottom),
            .init(name: "wallpaperDusk", color: .wallpaperDusk),
            .init(name: "wallpaperDuskTop", color: .wallpaperDuskTop),
            .init(name: "wallpaperDuskBottom", color: .wallpaperDuskBottom)
        ]
    }
}

private struct FocusModeColorToken: Identifiable {
    let name: String
    let color: Color
    var id: String { name }
}

private struct FocusModeFontRegistrationLogModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.task {
            FocusModeFontRegistrationLogger.logOnce()
        }
    }
}

@MainActor
private enum FocusModeFontRegistrationLogger {
    static var didLog = false
    static func logOnce() {
        guard !didLog else { return }
        didLog = true
        UIFont.registerFocusModeFonts()
        let families = UIFont.familyNames
            .filter { $0.contains("Newsreader") || $0.contains("JetBrains") }
            .sorted()
        for family in families {
            let names = UIFont.fontNames(forFamilyName: family).sorted().joined(separator: ", ")
            print("[DSKit FocusModeFont] \(family): \(names)")
        }
    }
}

#Preview("Focus Mode Tokens - Light") {
    FocusModeTokensPreview()
        .preferredColorScheme(.light)
}

#Preview("Focus Mode Tokens - Dark") {
    FocusModeTokensPreview()
        .preferredColorScheme(.dark)
}

#Preview("Focus Mode Tokens - Accessibility XXXLarge") {
    FocusModeTokensPreview()
        .preferredColorScheme(.light)
        .dynamicTypeSize(.accessibility3)
}

#Preview("Serif × Hangul fallback") {
    Text("작심 7일")
        .font(.jsSerifTitle)
        .foregroundStyle(Color.labelNormal)
        .padding(.jsXL)
        .background(Color.backgroundNormal)
        .preferredColorScheme(.light)
        .dynamicTypeSize(.accessibility3)
        .accessibilityLabel("serif hangul fallback preview")
}
