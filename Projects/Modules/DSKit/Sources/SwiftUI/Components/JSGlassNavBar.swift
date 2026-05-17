import SwiftUI

public struct JSGlassNavBarModifier: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .toolbarBackground(.thinMaterial, for: .navigationBar)
            .toolbarBackgroundVisibility(.automatic, for: .navigationBar)
            .accessibilityLabel("Liquid Glass navigation bar")
    }
}

public extension View {
    @MainActor
    func jsGlassNavBar() -> some View {
        modifier(JSGlassNavBarModifier())
    }
}

private struct JSGlassNavBarPreview: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.wallpaperDusk
                    .ignoresSafeArea()
                Text("5월의 기록")
                    .font(.jsSerifDisplay)
                    .foregroundStyle(Color.labelStrong)
            }
            .navigationTitle("작심")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "bell")
                    }
                    .accessibilityLabel("알림")
                }
            }
            .jsGlassNavBar()
        }
    }
}

#Preview("JSGlassNavBar - Light") {
    JSGlassNavBarPreview()
        .preferredColorScheme(.light)
}

#Preview("JSGlassNavBar - Dark") {
    JSGlassNavBarPreview()
        .preferredColorScheme(.dark)
}

#Preview("JSGlassNavBar - Accessibility") {
    JSGlassNavBarPreview()
        .dynamicTypeSize(.accessibility3)
}
