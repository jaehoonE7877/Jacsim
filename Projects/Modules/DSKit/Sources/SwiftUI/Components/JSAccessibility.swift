import SwiftUI

public struct JSTouchTargetModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
    }
}

public extension View {
    func jsTouchTarget() -> some View {
        modifier(JSTouchTargetModifier())
    }
}

public struct JSAccessibilityLabel: ViewModifier {
    let label: String
    let hint: String?
    let traits: AccessibilityTraits

    public init(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = []
    ) {
        self.label = label
        self.hint = hint
        self.traits = traits
    }

    public func body(content: Content) -> some View {
        content
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
}

public extension View {
    func jsAccessibility(
        _ label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        modifier(JSAccessibilityLabel(label: label, hint: hint, traits: traits))
    }
}

public struct JSAccessibilityGroup<Content: View>: View {
    let label: String
    let content: Content

    public init(
        _ label: String,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label
        self.content = content()
    }

    public var body: some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
    }
}

public struct JSAccessibilityHidden: ViewModifier {
    let isHidden: Bool

    public func body(content: Content) -> some View {
        content
            .accessibilityHidden(isHidden)
    }
}

public extension View {
    func jsAccessibilityHidden(_ hidden: Bool = true) -> some View {
        modifier(JSAccessibilityHidden(isHidden: hidden))
    }
}

public struct JSAccessibilityFocus<Content: View>: View {
    @AccessibilityFocusState private var isFocused: Bool
    let content: (AccessibilityFocusState<Bool>.Binding) -> Content

    public init(@ViewBuilder content: @escaping (AccessibilityFocusState<Bool>.Binding) -> Content) {
        self.content = content
    }

    public var body: some View {
        content($isFocused)
    }
}

public struct JSAccessibilityPreview: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                    Text("Touch Targets (44pt minimum)")
                        .font(.jsHeadline18Bold)

                    HStack(spacing: 12) {
                        Circle()
                            .fill(DSKitAsset.Colors.primary.swiftUIColor)
                            .frame(width: 30, height: 30)
                            .jsTouchTarget()
                            .background(DSKitAsset.Colors.gray100.swiftUIColor.opacity(0.1))

                        Text("Small visual, large touch area")
                            .font(.jsBody14Regular)
                            .foregroundColor(DSKitAsset.Colors.textSecondary.swiftUIColor)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Accessibility Labels")
                        .font(.jsHeadline18Bold)

                    HStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(DSKitAsset.Colors.semanticError.swiftUIColor)
                            .jsTouchTarget()
                            .jsAccessibility("Like", hint: "Double tap to like this item", traits: .isButton)

                        Text("Heart icon with accessibility label")
                            .font(.jsBody14Regular)
                            .foregroundColor(DSKitAsset.Colors.textSecondary.swiftUIColor)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Accessibility Groups")
                        .font(.jsHeadline18Bold)

                    JSAccessibilityGroup("Task: Complete project documentation, Due tomorrow") {
                        HStack {
                            Circle()
                                .fill(DSKitAsset.Colors.primary.swiftUIColor)
                                .frame(width: 12, height: 12)

                            VStack(alignment: .leading) {
                                Text("Complete project documentation")
                                    .font(.jsBody16Regular)
                                Text("Due tomorrow")
                                    .font(.jsLabel12Regular)
                                    .foregroundColor(DSKitAsset.Colors.textSecondary.swiftUIColor)
                            }
                        }
                    }
                    .padding(12)
                    .background(DSKitAsset.Colors.surfaceSecondary.swiftUIColor)
                    .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Hidden Elements")
                        .font(.jsHeadline18Bold)

                    HStack {
                        Text("Visible text")
                            .font(.jsBody16Regular)
                        Text("(Decorative)")
                            .font(.jsBody16Regular)
                            .foregroundColor(DSKitAsset.Colors.textSecondary.swiftUIColor)
                            .jsAccessibilityHidden()
                    }
                }
            }
            .padding()
        }
    }
}

struct JSAccessibility_Previews: PreviewProvider {
    static var previews: some View {
        JSAccessibilityPreview()
    }
}
