import SwiftUI
import ComposableArchitecture
import DSKit

public struct MainView: View {
    @Bindable var store: StoreOf<MainFeature>

    public init(store: StoreOf<MainFeature>) {
        self.store = store
    }

    public var body: some View {
        JSTabView(
            selectedTab: $store.selectedTab.sending(\.tabSelected),
            onTabSelected: { tab in
                store.send(.tabSelected(tab))
            }
        ) { tab in
            switch tab {
            case .home:
                HomeView(store: store.scope(state: \.home, action: \.home))
            case .calendar:
                CalendarView(store: store.scope(state: \.calendar, action: \.calendar))
            case .settings:
                SettingView(store: store.scope(state: \.setting, action: \.setting))
            }
        }
    }
}
