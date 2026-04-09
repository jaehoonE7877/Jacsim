import SwiftUI
import DesignSystem

private struct JSAccessibilityLabelModifier: ViewModifier {
    let label: String
    let hint: String?
    let traits: AccessibilityTraits

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
}

private struct SkeletonModifier<S: Shape & Sendable>: ViewModifier {
    let isLoading: Bool
    let shape: S

    func body(content: Content) -> some View {
        content
            .opacity(isLoading ? 0 : 1)
            .overlay(
                Group {
                    if isLoading {
                        shape
                            .fill(Color.skeletonBase)
                            .shimmering()
                    }
                }
            )
    }
}

private struct ShimmeringModifier: ViewModifier {
    @State private var sweepProgress: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0),
                            .init(color: Color.skeletonHighlight.opacity(0.1), location: 0.44),
                            .init(color: Color.skeletonHighlight.opacity(0.22), location: 0.5),
                            .init(color: Color.skeletonHighlight.opacity(0.1), location: 0.56),
                            .init(color: .clear, location: 1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(
                        width: proxy.size.width * 1.6,
                        height: proxy.size.height * 2.2
                    )
                    .rotationEffect(.degrees(-18))
                    .offset(x: proxy.size.width * sweepProgress)
                    .mask(content)
                }
            }
            .clipped()
            .onAppear {
                withAnimation(
                    .linear(duration: 1.8)
                    .repeatForever(autoreverses: false)
                ) {
                    sweepProgress = 1.35
                }
            }
    }
}

extension View {
    func jsAccessibility(
        _ label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        modifier(JSAccessibilityLabelModifier(label: label, hint: hint, traits: traits))
    }

    func skeleton<S: Shape & Sendable>(isLoading: Bool = true, shape: S) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading, shape: shape))
    }

    func skeleton(isLoading: Bool = true) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading, shape: Rectangle()))
    }

    func shimmering() -> some View {
        modifier(ShimmeringModifier())
    }
}
