import Foundation
import ComposableArchitecture

@Reducer
public struct MainFeature {
    @ObservableState
    public struct State: Equatable {
        public var home = HomeFeature.State()

        public init() {}
    }

    public enum Action {
        case home(HomeFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }

        Reduce { _, action in
            switch action {
            case .home:
                return .none
            }
        }
    }
}
