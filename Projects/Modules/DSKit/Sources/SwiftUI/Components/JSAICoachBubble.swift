import SwiftUI

public struct JSAICoachBubble: View {
    public enum Role: Sendable {
        case coach
        case user
        case typing
    }

    private let text: String
    private let role: Role
    private let accessibilityLabel: String

    public init(
        _ text: String = "",
        role: Role = .coach,
        accessibilityLabel: String? = nil
    ) {
        self.text = text
        self.role = role
        self.accessibilityLabel = accessibilityLabel ?? "\(role.accessibilityPrefix) message"
    }

    public var body: some View {
        HStack {
            if role == .user { Spacer(minLength: .jsXL) }
            bubble
            if role != .user { Spacer(minLength: .jsXL) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var bubble: some View {
        if role == .typing {
            TypingIndicator()
                .padding(.horizontal, .jsMD)
                .padding(.vertical, .jsSM)
                .bubbleStyle(role: role)
        } else {
            Text(text)
                .font(role == .coach ? .jsSerifQuote : .jsBodyMedium)
                .foregroundStyle(role == .coach ? Color.labelStrong : Color.backgroundNormal)
                .padding(.horizontal, .jsMD)
                .padding(.vertical, .jsSM)
                .bubbleStyle(role: role)
        }
    }
}

private extension JSAICoachBubble.Role {
    var accessibilityPrefix: String {
        switch self {
        case .coach: return "AI coach"
        case .user: return "User"
        case .typing: return "AI coach typing"
        }
    }
}

private struct BubbleStyleModifier: ViewModifier {
    let role: JSAICoachBubble.Role

    func body(content: Content) -> some View {
        content
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var background: some ShapeStyle {
        role == .user ? AnyShapeStyle(Color.forestAccent) : AnyShapeStyle(.thinMaterial)
    }
}

private extension View {
    func bubbleStyle(role: JSAICoachBubble.Role) -> some View {
        modifier(BubbleStyleModifier(role: role))
    }
}

private struct TypingIndicator: View {
    var body: some View {
        HStack(spacing: .jsMicro) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.forestAccent.opacity(0.72))
                    .frame(width: 7, height: 7)
                    .scaleEffect(index == 1 ? 1.18 : 1)
            }
        }
        .accessibilityLabel("AI coach is typing")
    }
}

private struct JSAICoachBubblePreview: View {
    var body: some View {
        VStack(spacing: .jsSM) {
            JSAICoachBubble("오늘은 10분만 해도 충분해요.", role: .coach)
            JSAICoachBubble("좋아요. 7시에 시작할게요.", role: .user)
            JSAICoachBubble(role: .typing)
        }
        .padding(.jsLG)
        .background(Color.backgroundNormal)
    }
}

#Preview("JSAICoachBubble - Light") {
    JSAICoachBubblePreview()
        .preferredColorScheme(.light)
}

#Preview("JSAICoachBubble - Dark") {
    JSAICoachBubblePreview()
        .preferredColorScheme(.dark)
}

#Preview("JSAICoachBubble - Accessibility") {
    JSAICoachBubblePreview()
        .dynamicTypeSize(.accessibility3)
}
