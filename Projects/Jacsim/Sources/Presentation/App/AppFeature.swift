import Foundation
import ComposableArchitecture

@Reducer
public struct AppFeature {
    @ObservableState
    public enum State: Equatable {
        case onboarding(WalkThroughFeature.State)
        case main(MainFeature.State)
        
        public init() {
            self = .onboarding(WalkThroughFeature.State(fromSetting: false))
        }
    }

    public enum Action {
        case onAppear
        case onboarding(WalkThroughFeature.Action)
        case main(MainFeature.Action)
    }

    @Dependency(\.appPreferences) var appPreferences

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let isOnboardingCompleted = appPreferences.isOnboardingCompleted()
                if isOnboardingCompleted, case .main = state {
                    return .none
                }
                if !isOnboardingCompleted, case .onboarding = state {
                    return .none
                }

                if isOnboardingCompleted {
                    state = .main(MainFeature.State())
                } else {
                    state = .onboarding(WalkThroughFeature.State(fromSetting: false))
                }
                return .none

            case .onboarding(.delegate(.completeOnboarding)):
                appPreferences.setOnboardingCompleted(true)
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
