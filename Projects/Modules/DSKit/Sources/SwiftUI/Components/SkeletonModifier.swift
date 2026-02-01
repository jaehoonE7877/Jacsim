import SwiftUI

public struct SkeletonModifier: ViewModifier {
    private let cornerRadius: CGFloat
    private let color: Color

    public init(cornerRadius: CGFloat, color: Color = Color.gray.opacity(0.2)) {
        self.cornerRadius = cornerRadius
        self.color = color
    }

    public func body(content: Content) -> some View {
        content
            .foregroundColor(.clear)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color)
            )
    }
}

public extension View {
    func skeleton(cornerRadius: CGFloat = 8, color: Color = Color.gray.opacity(0.2)) -> some View {
        modifier(SkeletonModifier(cornerRadius: cornerRadius, color: color))
    }
}
