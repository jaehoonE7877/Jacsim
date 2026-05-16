import SwiftUI

public enum JSV2StatusStyle {
    case accent
    case success
    case warning
    case danger
    case neutral
}

public struct JSV2StatusChip: View {
    private let title: String
    private let systemImage: String?
    private let style: JSV2StatusStyle
    private let isProminent: Bool

    public init(
        _ title: String,
        systemImage: String? = nil,
        style: JSV2StatusStyle = .neutral,
        isProminent: Bool = false
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.isProminent = isProminent
    }

    public var body: some View {
        HStack(spacing: 5.jsScaled()) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.jsLabel12Bold)
                    .accessibilityHidden(true)
            }

            Text(title)
                .font(.jsLabel12Bold)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .foregroundColor(foregroundColor)
        .padding(.horizontal, 10.jsScaled())
        .padding(.vertical, 6.jsScaled())
        .background(
            Capsule(style: .continuous)
                .fill(backgroundColor)
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(borderColor, lineWidth: isProminent ? 0 : 1)
        )
        .accessibilityElement(children: .combine)
    }

    private var foregroundColor: Color {
        if isProminent { return .white }
        switch style {
        case .accent:
            return .v2BrandBlue
        case .success:
            return .positive
        case .warning:
            return .cautionary
        case .danger:
            return .destructive
        case .neutral:
            return .labelNeutral
        }
    }

    private var backgroundColor: Color {
        if isProminent {
            switch style {
            case .accent:
                return .v2BrandBlue
            case .success:
                return .positive
            case .warning:
                return .cautionary
            case .danger:
                return .destructive
            case .neutral:
                return .labelNeutral
            }
        }

        switch style {
        case .accent:
            return .v2BrandBlueSoft
        case .success:
            return .positive.opacity(0.12)
        case .warning:
            return .cautionary.opacity(0.14)
        case .danger:
            return .destructive.opacity(0.12)
        case .neutral:
            return .v2Surface
        }
    }

    private var borderColor: Color {
        switch style {
        case .accent:
            return .v2BrandBlue.opacity(0.14)
        case .success:
            return .positive.opacity(0.16)
        case .warning:
            return .cautionary.opacity(0.18)
        case .danger:
            return .destructive.opacity(0.16)
        case .neutral:
            return .labelAssistive.opacity(0.25)
        }
    }
}

public struct JSV2MetricPill: View {
    private let title: String
    private let value: String
    private let systemImage: String?
    private let style: JSV2StatusStyle

    public init(
        title: String,
        value: String,
        systemImage: String? = nil,
        style: JSV2StatusStyle = .neutral
    ) {
        self.title = title
        self.value = value
        self.systemImage = systemImage
        self.style = style
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6.jsScaled()) {
            HStack(spacing: 5.jsScaled()) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.jsLabel12Bold)
                        .accessibilityHidden(true)
                }

                Text(title)
                    .font(.jsLabel12Medium)
                    .foregroundColor(.labelAlternative)
                    .lineLimit(1)
            }

            Text(value)
                .font(.jsHeadline18Bold)
                .foregroundColor(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.jsSM)
        .background(
            RoundedRectangle(cornerRadius: 16.jsScaled(), style: .continuous)
                .fill(Color.v2SurfaceElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16.jsScaled(), style: .continuous)
                .stroke(Color.labelAssistive.opacity(0.18), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title) \(value)")
    }

    private var valueColor: Color {
        switch style {
        case .accent:
            return .v2BrandBlue
        case .success:
            return .positive
        case .warning:
            return .cautionary
        case .danger:
            return .destructive
        case .neutral:
            return .labelStrong
        }
    }
}

public struct JSV2SectionHeader: View {
    private let title: String
    private let actionTitle: String?
    private let action: (() -> Void)?

    public init(
        _ title: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.jsHeadlineMedium)
                .foregroundColor(.labelStrong)

            Spacer()

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.jsButtonSmall)
                        .foregroundColor(.v2BrandBlue)
                        .frame(minHeight: .jsTouchTarget)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(actionTitle)
            }
        }
    }
}

public extension View {
    func jsv2CardSurface(
        cornerRadius: CGFloat = 22.jsScaled(),
        shadowOpacity: Double = 0.08
    ) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.v2SurfaceElevated)
                .shadow(
                    color: Color.labelStrong.opacity(shadowOpacity),
                    radius: 18.jsScaled(),
                    x: 0,
                    y: 8.jsScaled()
                )
        )
    }
}
