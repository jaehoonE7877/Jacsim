import SwiftUI

public struct AnimatedSkeletonModifier: ViewModifier {
    private let cornerRadius: CGFloat
    private let baseColor: Color
    private let shimmerColor: Color
    @State private var isAnimating = false
    
    public init(
        cornerRadius: CGFloat,
        baseColor: Color = Color.gray.opacity(0.15),
        shimmerColor: Color = Color.white.opacity(0.4)
    ) {
        self.cornerRadius = cornerRadius
        self.baseColor = baseColor
        self.shimmerColor = shimmerColor
    }
    
    public func body(content: Content) -> some View {
        content
            .foregroundColor(.clear)
            .background(
                GeometryReader { geometry in
                    ZStack {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(baseColor)
                        
                        LinearGradient(
                            gradient: Gradient(colors: [
                                shimmerColor.opacity(0),
                                shimmerColor,
                                shimmerColor.opacity(0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 0.6)
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                        .mask(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Color.white)
                        )
                    }
                }
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

public extension View {
    func animatedSkeleton(
        cornerRadius: CGFloat = 8,
        baseColor: Color = Color.gray.opacity(0.15),
        shimmerColor: Color = Color.white.opacity(0.4)
    ) -> some View {
        modifier(AnimatedSkeletonModifier(
            cornerRadius: cornerRadius,
            baseColor: baseColor,
            shimmerColor: shimmerColor
        ))
    }
}
