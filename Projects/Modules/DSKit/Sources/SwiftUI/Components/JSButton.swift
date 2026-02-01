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
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
        .frame(minHeight: 44)
    }

    private var font: Font {
        switch size {
        case .large:
            return .system(size: 18, weight: .semibold)
        case .medium:
            return .system(size: 16, weight: .semibold)
        case .small:
            return .system(size: 14, weight: .medium)
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .large:
            return 16
        case .medium:
            return 12
        case .small:
            return 8
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .large:
            return 24
        case .medium:
            return 20
        case .small:
            return 16
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary, .ghost:
            return isEnabled ? .blue : .gray
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .blue
        case .secondary:
            return Color(.systemBackground)
        case .destructive:
            return .red
        case .ghost:
            return .clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary, .destructive:
            return .clear
        case .secondary:
            return .gray
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
