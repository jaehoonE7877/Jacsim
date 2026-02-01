import Foundation
import ComposableArchitecture

@Reducer
public struct AppFeature {
    @ObservableState
    public enum State: Equatable {
        case onboarding(WalkThroughFeature.State)
        case main(MainFeature.State)
        
        public init() {
            let isOnboarded = UserDefaults.standard.bool(forKey: "onboarding")
            if isOnboarded {
                self = .main(MainFeature.State())
            } else {
                self = .onboarding(WalkThroughFeature.State(fromSetting: false))
            }
        }
    }

    public enum Action {
        case onboarding(WalkThroughFeature.Action)
        case main(MainFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onboarding(.delegate(.completeOnboarding)):
                UserDefaults.standard.set(true, forKey: "onboarding")
                state = .main(MainFeature.State())
                return .none
                
            case .onboarding, .main:
                return .none
            }
        }
        .ifCaseLet(\.onboarding, action: \.onboarding) {
            WalkThroughFeature()
        }
        .ifCaseLet(\.main, action: \.main) {
            MainFeature()
        }
    }
}
