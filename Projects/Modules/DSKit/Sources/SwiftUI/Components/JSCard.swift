import SwiftUI

public enum JSCardStyle {
    case elevated
    case outlined
    case flat
}

public struct JSCard<Content: View>: View {
    let style: JSCardStyle
    let padding: CGFloat
    let content: Content

    public init(
        style: JSCardStyle = .elevated,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
    }

    private var borderColor: Color {
        switch style {
        case .outlined:
            return Color.gray.opacity(0.3)
        case .elevated, .flat:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .outlined:
            return 1
        case .elevated, .flat:
            return 0
        }
    }

    private var shadowColor: Color {
        switch style {
        case .elevated:
            return .black.opacity(0.08)
        case .outlined, .flat:
            return .clear
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .elevated:
            return 8
        case .outlined, .flat:
            return 0
        }
    }

    private var shadowY: CGFloat {
        switch style {
        case .elevated:
            return 4
        case .outlined, .flat:
            return 0
        }
    }
}

struct JSCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                JSCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Elevated Card")
                            .font(.system(size: 16, weight: .semibold))
                        Text("This card has a subtle shadow for depth")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }

                JSCard(style: .outlined) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Outlined Card")
                            .font(.system(size: 16, weight: .semibold))
                        Text("This card has a border instead of shadow")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }

                JSCard(style: .flat) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Flat Card")
                            .font(.system(size: 16, weight: .semibold))
                        Text("This card has no shadow or border")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }

                JSCard(padding: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom Padding")
                            .font(.system(size: 16, weight: .semibold))
                        Text("This card has extra large padding")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }

                JSCard {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.blue)
                            .frame(width: 48, height: 48)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Complex Layout")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Cards can contain any content")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}
