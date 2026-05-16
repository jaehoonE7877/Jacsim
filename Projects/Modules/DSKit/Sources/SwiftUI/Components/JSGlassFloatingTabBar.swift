import SwiftUI

public struct JSGlassFloatingTabBar: View {
    @Binding private var selection: JSTabItem
    private let onSelect: (JSTabItem) -> Void
    private let onPlusTap: () -> Void

    public init(
        selection: Binding<JSTabItem>,
        onSelect: @escaping (JSTabItem) -> Void = { _ in },
        onPlusTap: @escaping () -> Void = {}
    ) {
        self._selection = selection
        self.onSelect = onSelect
        self.onPlusTap = onPlusTap
    }

    public var body: some View {
        HStack(spacing: .jsMicro) {
            ForEach(JSTabItem.allCases, id: \.self) { item in
                Button {
                    handleTap(item)
                } label: {
                    tabContent(for: item)
                }
                .buttonStyle(.plain)
                .jsTouchTarget()
                .accessibilityLabel(accessibilityLabel(for: item))
            }
        }
        .frame(height: 64)
        .padding(.horizontal, .jsMicro)
        .glassEffect(.regular, in: .rect(cornerRadius: 32))
        .padding(.horizontal, .jsTabBarMargin)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Liquid Glass floating tab bar")
    }

    private func handleTap(_ item: JSTabItem) {
        if item == .plus {
            onPlusTap()
            return
        }
        selection = item
        onSelect(item)
    }

    private func tabContent(for item: JSTabItem) -> some View {
        let isSelected = selection == item
        return ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(item == .plus ? Color.forestAccent : selectedBackground(isSelected))

            Image(systemName: item.icon)
                .font(item == .plus ? .jsHeadline20Bold : .jsBody16Medium)
                .foregroundStyle(item == .plus ? Color.backgroundNormal : selectedForeground(isSelected))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .animation(JSAnimation.spring, value: selection)
    }

    private func selectedBackground(_ selected: Bool) -> Color {
        selected ? Color.surfaceSelected.opacity(0.78) : Color.surfaceElevated.opacity(0.18)
    }

    private func selectedForeground(_ selected: Bool) -> Color {
        selected ? Color.forestAccent : Color.labelAlternative
    }

    private func accessibilityLabel(for item: JSTabItem) -> String {
        item == .plus ? "새 작심 추가" : "\(item.title) 탭"
    }
}

private struct JSGlassFloatingTabBarPreview: View {
    @State private var selection: JSTabItem = .today

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient.wallpaperForest
                .ignoresSafeArea()
            JSGlassFloatingTabBar(selection: $selection)
                .padding(.bottom, .jsLG)
        }
    }
}

#Preview("JSGlassFloatingTabBar - Light") {
    JSGlassFloatingTabBarPreview()
        .preferredColorScheme(.light)
}

#Preview("JSGlassFloatingTabBar - Dark") {
    JSGlassFloatingTabBarPreview()
        .preferredColorScheme(.dark)
}

#Preview("JSGlassFloatingTabBar - Accessibility") {
    JSGlassFloatingTabBarPreview()
        .dynamicTypeSize(.accessibility3)
}
