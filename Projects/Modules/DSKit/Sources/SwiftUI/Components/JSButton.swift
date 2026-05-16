import SwiftUI

public enum JSButtonStyle {
    case primary
    case secondary
    case destructive
    case ghost
}

public enum JSButtonSize {
    case large
    case medium
    case small
}

public struct JSButton: View {
    let title: String
    let style: JSButtonStyle
    let size: JSButtonSize
    let isEnabled: Bool
    let action: () -> Void

    public init(
        title: String,
        style: JSButtonStyle = .primary,
        size: JSButtonSize = .medium,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, horizontalPadding)
                .background(backgroundColor)
                .cornerRadius(.jsCornerSmall)
                .overlay(
                    RoundedRectangle(cornerRadius: .jsCornerSmall)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
        .frame(minWidth: 44.jsScaled(.touchTarget), minHeight: 44.jsScaled(.touchTarget))
    }

    private var font: Font {
        switch size {
        case .large:
            return .jsButtonLarge
        case .medium:
            return .jsButtonMedium
        case .small:
            return .jsButtonSmall
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .large:
            return 16.jsScaled()
        case .medium:
            return 12.jsScaled()
        case .small:
            return 8.jsScaled()
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .large:
            return 24.jsScaled()
        case .medium:
            return 20.jsScaled()
        case .small:
            return 16.jsScaled()
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary, .ghost:
            return isEnabled ? .primaryNormal : .labelNeutral
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .primaryNormal
        case .secondary:
            return .backgroundNormal
        case .destructive:
            return .destructive
        case .ghost:
            return .clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary, .destructive:
            return .clear
        case .secondary:
            return .labelNeutral
        case .ghost:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .secondary:
            return 1
        default:
            return 0
        }
    }
}

struct JSButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            JSButton(title: "Primary Large", style: .primary, size: .large) {}
            JSButton(title: "Primary Medium", style: .primary, size: .medium) {}
            JSButton(title: "Primary Small", style: .primary, size: .small) {}

            JSButton(title: "Secondary", style: .secondary) {}
            JSButton(title: "Destructive", style: .destructive) {}
            JSButton(title: "Ghost", style: .ghost) {}
            JSButton(title: "Disabled", isEnabled: false) {}
        }
        .padding()
    }
}
