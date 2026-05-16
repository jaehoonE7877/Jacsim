import Foundation
import SwiftUI

public struct JSGlassToastModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding private var isPresented: Bool
    private let duration: TimeInterval

    public init(
        isPresented: Binding<Bool>,
        duration: TimeInterval = 3.0
    ) {
        self._isPresented = isPresented
        self.duration = duration
    }

    public func body(content: Content) -> some View {
        content
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: .jsCornerExtraLarge))
            .opacity(isPresented ? 1 : 0)
            .offset(y: isPresented ? 0 : 0 - .jsLG)
            .allowsHitTesting(isPresented)
            .accessibilityHidden(!isPresented)
            .transition(reduceMotion ? .identity : .move(edge: .top).combined(with: .opacity))
            .animation(reduceMotion ? nil : JSAnimation.spring, value: isPresented)
            .sensoryFeedback(.impact(weight: .light), trigger: isPresented)
            .task(id: isPresented) {
                guard isPresented, duration > 0 else { return }

                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))

                guard !Task.isCancelled else { return }
                await MainActor.run {
                    isPresented = false
                }
            }
    }
}

public extension View {
    @MainActor
    func jsGlassCard(cornerRadius: CGFloat = 24) -> some View {
        glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
    }

    @MainActor
    func jsGlassSheet() -> some View {
        presentationBackground(.thinMaterial)
            .presentationDragIndicator(.visible)
    }

    @MainActor
    func jsGlassNavPill() -> some View {
        toolbarBackground(.thinMaterial, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
    }

    @MainActor
    func jsGlassToast(
        isPresented: Binding<Bool>,
        duration: TimeInterval = 3.0
    ) -> some View {
        modifier(JSGlassToastModifier(isPresented: isPresented, duration: duration))
    }
}

private struct LiquidGlassDSKitPreview: View {
    @State private var isSheetPresented = true
    @State private var isToastPresented = true

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.backgroundAlternative
                    .ignoresSafeArea()

                VStack(spacing: .jsXL) {
                    Text("Glass Card")
                        .font(.jsBodyMedium)
                        .foregroundColor(.labelNormal)
                        .padding(.jsXL)
                        .jsGlassCard()
                        .accessibilityLabel("Liquid Glass card preview")

                    Button("Toast") {
                        isToastPresented = true
                    }
                    .font(.jsButtonMedium)
                    .buttonStyle(.glassProminent)
                    .accessibilityLabel("Show Liquid Glass toast")
                }
                .padding(.jsXL)

                Text("Glass Toast")
                    .font(.jsBodyMedium)
                    .foregroundColor(.labelNormal)
                    .padding(.horizontal, .jsLG)
                    .padding(.vertical, .jsSM)
                    .jsGlassToast(isPresented: $isToastPresented)
                    .padding(.top, .jsLG)
                    .accessibilityLabel("Liquid Glass toast preview")
            }
            .navigationTitle("Liquid Glass")
            .jsGlassNavPill()
            .sheet(isPresented: $isSheetPresented) {
                Text("Glass Sheet")
                    .font(.jsBodyMedium)
                    .foregroundColor(.labelNormal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.backgroundNormal)
                    .jsGlassSheet()
                    .presentationDetents([.height(220)])
                    .accessibilityLabel("Liquid Glass sheet preview")
            }
        }
    }
}

#Preview("Liquid Glass Helpers - Light") {
    LiquidGlassDSKitPreview()
        .preferredColorScheme(.light)
}

#Preview("Liquid Glass Helpers - Dark") {
    LiquidGlassDSKitPreview()
        .preferredColorScheme(.dark)
}
