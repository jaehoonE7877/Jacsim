import SwiftUI

public struct JSGlassToast: View {
    private let text: String

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.jsBodyMedium)
            .foregroundStyle(Color.labelStrong)
            .padding(.horizontal, .jsLG)
            .padding(.vertical, .jsSM)
            .background(Color.surfaceElevated.opacity(0.34))
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 22))
            .accessibilityLabel(text)
    }
}

public struct JSGlassToastTextModifier: ViewModifier {
    @Binding private var text: String?
    @Binding private var isPresented: Bool
    private let duration: TimeInterval

    public init(
        text: Binding<String?>,
        isPresented: Binding<Bool>,
        duration: TimeInterval = 3.0
    ) {
        self._text = text
        self._isPresented = isPresented
        self.duration = duration
    }

    public func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if isPresented, let text {
                    JSGlassToast(text: text)
                        .padding(.top, .jsLG)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .sensoryFeedback(.impact(weight: .light), trigger: isPresented)
            .animation(JSAnimation.spring, value: isPresented)
            .task(id: isPresented) {
                guard isPresented, duration > 0 else { return }
                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    isPresented = false
                    text = nil
                }
            }
    }
}

public extension View {
    @MainActor
    func jsGlassToast(
        text: Binding<String?>,
        isPresented: Binding<Bool>,
        duration: TimeInterval = 3.0
    ) -> some View {
        modifier(JSGlassToastTextModifier(text: text, isPresented: isPresented, duration: duration))
    }
}

private struct JSGlassToastPreview: View {
    @State private var toastText: String? = "작심이 저장됐어요"
    @State private var isPresented = true

    var body: some View {
        ZStack {
            LinearGradient.wallpaperForest
                .ignoresSafeArea()
            Button("Show Toast") {
                toastText = "오늘도 이어졌어요"
                isPresented = true
            }
            .font(.jsButtonMedium)
            .buttonStyle(.glassProminent)
            .accessibilityLabel("토스트 보기")
        }
        .jsGlassToast(text: $toastText, isPresented: $isPresented)
    }
}

#Preview("JSGlassToast - Light") {
    JSGlassToastPreview()
        .preferredColorScheme(.light)
}

#Preview("JSGlassToast - Dark") {
    JSGlassToastPreview()
        .preferredColorScheme(.dark)
}

#Preview("JSGlassToast - Accessibility") {
    JSGlassToastPreview()
        .dynamicTypeSize(.accessibility3)
}
