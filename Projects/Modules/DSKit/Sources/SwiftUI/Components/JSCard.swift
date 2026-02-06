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
            .background(Color.backgroundNormal)
            .cornerRadius(.jsCornerSmall)
            .overlay(
                RoundedRectangle(cornerRadius: .jsCornerSmall)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .jsShadow(shadowStyle)
    }

    private var borderColor: Color {
        switch style {
        case .outlined:
            return .labelAlternative
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

    private var shadowStyle: ShadowStyle {
        switch style {
        case .elevated:
            return .small
        case .outlined, .flat:
            return .clear
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
                            .font(.jsHeadlineSmall)
                        Text("This card has a subtle shadow for depth")
                            .font(.jsBodySmall)
                            .foregroundColor(.labelAlternative)
                    }
                }

                JSCard(style: .outlined) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Outlined Card")
                            .font(.jsHeadlineSmall)
                        Text("This card has a border instead of shadow")
                            .font(.jsBodySmall)
                            .foregroundColor(.labelAlternative)
                    }
                }

                JSCard(style: .flat) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Flat Card")
                            .font(.jsHeadlineSmall)
                        Text("This card has no shadow or border")
                            .font(.jsBodySmall)
                            .foregroundColor(.labelAlternative)
                    }
                }

                JSCard(padding: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom Padding")
                            .font(.jsHeadlineSmall)
                        Text("This card has extra large padding")
                            .font(.jsBodySmall)
                            .foregroundColor(.labelAlternative)
                    }
                }

                JSCard {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.primaryNormal)
                            .frame(width: 48, height: 48)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Complex Layout")
                                .font(.jsHeadlineSmall)
                            Text("Cards can contain any content")
                                .font(.jsBodySmall)
                                .foregroundColor(.labelAlternative)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.labelNeutral)
                    }
                }
            }
            .padding()
        }
        .background(Color.backgroundAlternative)
    }
}
