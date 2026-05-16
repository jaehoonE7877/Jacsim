import SwiftUI

public struct JSGlassCard<Content: View>: View {
    private let cornerRadius: CGFloat
    private let accessibilityLabel: String
    private let content: Content

    public init(
        cornerRadius: CGFloat = 24,
        accessibilityLabel: String = "Liquid Glass card",
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.accessibilityLabel = accessibilityLabel
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.jsLG)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surfaceElevated.opacity(0.2))
            .jsGlassCard(cornerRadius: cornerRadius)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
    }
}

private struct JSGlassCardPreview: View {
    var body: some View {
        ZStack {
            LinearGradient.wallpaperMorning
                .ignoresSafeArea()
            JSGlassCard(accessibilityLabel: "오늘의 작심 카드") {
                VStack(alignment: .leading, spacing: .jsSM) {
                    Text("오늘의 작심")
                        .font(.jsSerifTitle)
                        .foregroundStyle(Color.labelStrong)
                    Text("작게 시작해요")
                        .font(.jsBodyMedium)
                        .foregroundStyle(Color.labelNeutral)
                }
            }
            .padding(.jsXL)
        }
    }
}

#Preview("JSGlassCard - Light") {
    JSGlassCardPreview()
        .preferredColorScheme(.light)
}

#Preview("JSGlassCard - Dark") {
    JSGlassCardPreview()
        .preferredColorScheme(.dark)
}

#Preview("JSGlassCard - Accessibility") {
    JSGlassCardPreview()
        .dynamicTypeSize(.accessibility3)
}
