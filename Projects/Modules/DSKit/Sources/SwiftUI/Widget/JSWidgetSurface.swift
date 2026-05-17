import SwiftUI

public struct JSWidgetSurface<Content: View>: View {
    public enum Size: Sendable {
        case small
        case medium
        case large

        var cornerRadius: CGFloat {
            switch self {
            case .small: return 22
            case .medium: return 26
            case .large: return 30
            }
        }
    }

    private let size: Size
    private let accessibilityLabel: String
    private let content: Content

    public init(
        size: Size = .medium,
        accessibilityLabel: String = "Widget surface",
        @ViewBuilder content: () -> Content
    ) {
        self.size = size
        self.accessibilityLabel = accessibilityLabel
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                .fill(Color.surfaceElevated.opacity(0.22))
                .glassEffect(.regular, in: .rect(cornerRadius: size.cornerRadius))

            content
                .padding(size == .small ? .jsMD : .jsLG)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
    }
}

private struct JSWidgetSurfacePreview: View {
    var body: some View {
        VStack(spacing: .jsMD) {
            JSWidgetSurface(size: .small, accessibilityLabel: "작심 위젯 작은 크기") {
                Text("D-3")
                    .font(.jsMonoLarge)
                    .foregroundStyle(Color.forestAccent)
            }
            .frame(width: 160, height: 160)

            JSWidgetSurface(size: .medium, accessibilityLabel: "작심 위젯 중간 크기") {
                VStack(alignment: .leading, spacing: .jsXS) {
                    Text("오늘의 작심")
                        .font(.jsSerifTitle)
                        .foregroundStyle(Color.labelStrong)
                    Text("10분만 이어가기")
                        .font(.jsBodyMedium)
                        .foregroundStyle(Color.labelNeutral)
                }
            }
            .frame(width: 320, height: 160)
        }
        .padding(.jsXL)
        .background(LinearGradient.wallpaperForest)
    }
}

#Preview("JSWidgetSurface - Light") {
    JSWidgetSurfacePreview()
        .preferredColorScheme(.light)
}

#Preview("JSWidgetSurface - Dark") {
    JSWidgetSurfacePreview()
        .preferredColorScheme(.dark)
}

#Preview("JSWidgetSurface - Accessibility") {
    JSWidgetSurfacePreview()
        .dynamicTypeSize(.accessibility3)
}
