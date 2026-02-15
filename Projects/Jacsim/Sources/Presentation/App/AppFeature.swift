import Foundation
import ComposableArchitecture

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        public var onboarding: WalkThroughFeature.State?
        public var main: MainFeature.State?
        public var themeRaw: String
        
        public init() {
            self.onboarding = WalkThroughFeature.State(fromSetting: false)
            self.main = nil
            self.themeRaw = ThemeMode.system.rawValue
        }
    }

    public enum Action {
        case onAppear
        case themePreferenceRefreshRequested
        case onboarding(WalkThroughFeature.Action)
        case main(MainFeature.Action)
    }

    @Dependency(\.appPreferencesUseCase) var appPreferencesUseCase

    private func resolvedThemeRaw() -> String {
        guard let raw = appPreferencesUseCase.getThemeModeRaw(),
              ThemeMode(rawValue: raw) != nil else {
            return ThemeMode.system.rawValue
        }
        return raw
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let isOnboardingCompleted = appPreferencesUseCase.isOnboardingCompleted()
                state.themeRaw = resolvedThemeRaw()

                if isOnboardingCompleted, state.main != nil {
                    return .none
                }
                if !isOnboardingCompleted, state.onboarding != nil {
                    return .none
                }

                if isOnboardingCompleted {
                    state.main = MainFeature.State()
                    state.onboarding = nil
                } else {
                    state.onboarding = WalkThroughFeature.State(fromSetting: false)
                    state.main = nil
                }
                return .none

            case .themePreferenceRefreshRequested:
                state.themeRaw = resolvedThemeRaw()
                return .none

            case .onboarding(.delegate(.completeOnboarding)):
                appPreferencesUseCase.setOnboardingCompleted(true)
                state.main = MainFeature.State()
                state.onboarding = nil
                state.themeRaw = resolvedThemeRaw()
                return .none
                
            case .onboarding, .main:
                return .none
            }
        }
        .ifLet(\.onboarding, action: \.onboarding) {
            WalkThroughFeature()
        }
        .ifLet(\.main, action: \.main) {
            MainFeature()
        }
    }
}
