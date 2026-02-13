import SwiftUI

public struct SkeletonModifier<S: Shape & Sendable>: ViewModifier {
    private let isLoading: Bool
    private let shape: S

    public init(isLoading: Bool, shape: S) {
        self.isLoading = isLoading
        self.shape = shape
    }

    public func body(content: Content) -> some View {
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

public struct ShimmeringModifier: ViewModifier {
    @State private var sweepProgress: CGFloat = -1

    public func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    shimmerGradient
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

    private var shimmerGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .clear, location: 0.0),
                .init(color: Color.skeletonHighlight.opacity(0.1), location: 0.44),
                .init(color: Color.skeletonHighlight.opacity(0.22), location: 0.5),
                .init(color: Color.skeletonHighlight.opacity(0.1), location: 0.56),
                .init(color: .clear, location: 1.0)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

public extension View {
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
