import Foundation
import ComposableArchitecture
import DSKit

@Reducer
public struct MainFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedTab: JSTabItem = .home
        public var home = HomeFeature.State()
        public var calendar = CalendarFeature.State()
        public var setting = SettingFeature.State()
        
        public init() {}
    }

    public enum Action {
        case tabSelected(JSTabItem)
        case home(HomeFeature.Action)
        case calendar(CalendarFeature.Action)
        case setting(SettingFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Scope(state: \.calendar, action: \.calendar) {
            CalendarFeature()
        }
        Scope(state: \.setting, action: \.setting) {
            SettingFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case .home, .calendar, .setting:
                return .none
            }
        }
    }
}
