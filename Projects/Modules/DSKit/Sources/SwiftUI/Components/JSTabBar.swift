import SwiftUI

public enum JSTabItem: CaseIterable {
    case today
    case calendar
    case plus
    case feed
    case me
    @available(*, deprecated, message: "Use JSGlassFloatingTabBar")
    case home
    @available(*, deprecated, message: "Use JSGlassFloatingTabBar")
    case settings

    public static var allCases: [JSTabItem] {
        [.today, .calendar, .plus, .feed, .me]
    }

    static var legacyCases: [JSTabItem] {
        [.home, .calendar, .settings]
    }

    var icon: String {
        switch self {
        case .today:
            return "sun.max.fill"
        case .home:
            return "house.fill"
        case .calendar:
            return "calendar"
        case .plus:
            return "plus"
        case .feed:
            return "person.2.fill"
        case .me:
            return "person.crop.circle.fill"
        case .settings:
            return "gearshape.fill"
        }
    }

    var title: String {
        switch self {
        case .today:
            return "오늘"
        case .home:
            return "홈"
        case .calendar:
            return "캘린더"
        case .plus:
            return "추가"
        case .feed:
            return "피드"
        case .me:
            return "나"
        case .settings:
            return "설정"
        }
    }
}

@available(*, deprecated, message: "Use JSGlassFloatingTabBar")
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
            ForEach(JSTabItem.legacyCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(
            Color.backgroundNormal
                .jsShadow(.medium)
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
                    .font(.jsHeadline20Bold)
                    .foregroundColor(isSelected ? Color.primaryNormal : .labelNeutral)
                    .frame(height: 24)

                Text(tab.title)
                    .font(.jsLabel10Regular)
                    .foregroundColor(isSelected ? Color.primaryNormal : .labelNeutral)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(Rectangle())
    }
}

@available(*, deprecated, message: "Use JSGlassFloatingTabBar")
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
                    onTabSelected: { _ in }
                ) { tab in
                    VStack {
                        Spacer()
                        Text("Current Tab: \(tab.title)")
                            .font(.jsHeadline20Bold)
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
