import SwiftUI

public enum JSTabItem: CaseIterable {
    case home
    case calendar
    case settings

    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .calendar:
            return "calendar"
        case .settings:
            return "gearshape.fill"
        }
    }

    var title: String {
        switch self {
        case .home:
            return "홈"
        case .calendar:
            return "캘린더"
        case .settings:
            return "설정"
        }
    }
}

public struct JSTabBar: View {
    @Binding var selectedTab: JSTabItem
    let onTabSelected: ((JSTabItem) -> Void)?

    public init(
        selectedTab: Binding<JSTabItem>,
        onTabSelected: ((JSTabItem) -> Void)? = nil
    ) {
        self._selectedTab = selectedTab
        self.onTabSelected = onTabSelected
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(JSTabItem.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(
            Color(.systemBackground)
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 8,
                    x: 0,
                    y: -2
                )
        )
    }

    private func tabButton(for tab: JSTabItem) -> some View {
        let isSelected = selectedTab == tab

        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
            onTabSelected?(tab)
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .blue : .gray)
                    .frame(height: 24)

                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(Rectangle())
    }
}

public struct JSTabView<Content: View>: View {
    @Binding var selectedTab: JSTabItem
    let onTabSelected: ((JSTabItem) -> Void)?
    let content: (JSTabItem) -> Content

    public init(
        selectedTab: Binding<JSTabItem>,
        onTabSelected: ((JSTabItem) -> Void)? = nil,
        @ViewBuilder content: @escaping (JSTabItem) -> Content
    ) {
        self._selectedTab = selectedTab
        self.onTabSelected = onTabSelected
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            content(selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            JSTabBar(
                selectedTab: $selectedTab,
                onTabSelected: onTabSelected
            )
        }
    }
}

struct JSTabBar_Previews: PreviewProvider {
    struct PreviewContainer: View {
        @State private var selectedTab: JSTabItem = .home

        var body: some View {
            VStack(spacing: 0) {
                JSTabView(
                    selectedTab: $selectedTab,
                    onTabSelected: { tab in
                        print("Selected: \(tab)")
                    }
                ) { tab in
                    VStack {
                        Spacer()
                        Text("Current Tab: \(tab.title)")
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                    }
                }
            }
        }
    }

    static var previews: some View {
        PreviewContainer()
    }
}
