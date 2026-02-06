import SwiftUI

public struct SkeletonModifier: ViewModifier {
    private let isLoading: Bool
    private let shape: AnyShape

    public init(isLoading: Bool, shape: some Shape) {
        self.isLoading = isLoading
        self.shape = AnyShape(shape)
    }

    public func body(content: Content) -> some View {
        content
            .opacity(isLoading ? 0 : 1)
            .overlay(
                Group {
                    if isLoading {
                        shape
                            .fill(Color.surfaceOverlay.opacity(0.1)) // Keep generic gray for skeleton base
                            .shimmering()
                    }
                }
            )
    }
}

public struct ShimmeringModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    public func body(content: Content) -> some View {
        content
            .modifier(AnimatedMask(phase: phase))
            .onAppear {
                withAnimation(
                    .linear(duration: 2.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1.0
                }
            }
    }
}

public struct AnimatedMask: AnimatableModifier {
    var phase: CGFloat

    public var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    public func body(content: Content) -> some View {
        content
            .mask(
                GradientMask(phase: phase)
                    .scaleEffect(3)
            )
    }
}

public struct GradientMask: View {
    let phase: CGFloat

    private let centerColor = Color.surfaceOverlay.opacity(0.3)
    private let edgeColor = Color.surfaceOverlay.opacity(1.0)

    public var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: edgeColor, location: phase),
                    .init(color: centerColor, location: phase + 0.1),
                    .init(color: edgeColor, location: phase + 0.2)
                ]),
                startPoint: UnitPoint(x: 0, y: 0.5),
                endPoint: UnitPoint(x: 1, y: 0.5)
            )
            .rotationEffect(.degrees(-45))
            .offset(x: -geometry.size.width, y: -geometry.size.height)
            .frame(width: geometry.size.width * 3, height: geometry.size.height * 3)
        }
    }
}

public extension View {
    func skeleton(isLoading: Bool = true, shape: some Shape = Rectangle()) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading, shape: shape))
    }

    func shimmering() -> some View {
        modifier(ShimmeringModifier())
    }
}

public struct AnyShape: Shape {
    private let path: (CGRect) -> Path

    public init<S: Shape>(_ shape: S) {
        self.path = { rect in
            shape.path(in: rect)
        }
    }

    public func path(in rect: CGRect) -> Path {
        path(rect)
    }
}
