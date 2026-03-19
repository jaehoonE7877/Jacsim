import Foundation
import ComposableArchitecture
import JacsimClient
import SwiftUI

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        public var onboarding: WalkThroughFeature.State?
        public var home: HomeFeature.State?
        public var themeRaw: String
        
        public init() {
            self.onboarding = WalkThroughFeature.State(fromSetting: false)
            self.home = nil
            self.themeRaw = ThemeMode.system.rawValue
        }
    }

    public enum Action {
        case onAppear
        case scenePhaseChanged(ScenePhase)
        case themePreferenceRefreshRequested
        case onboarding(WalkThroughFeature.Action)
        case home(HomeFeature.Action)
    }

    @Dependency(\.appPreferences) var appPreferences
    @Dependency(\.reminderSchedulingUseCase) var reminderSchedulingUseCase

    private func resolvedThemeRaw() -> String {
        guard let raw = appPreferences.getThemeModeRaw(),
              ThemeMode(rawValue: raw) != nil else {
            return ThemeMode.system.rawValue
        }
        return raw
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let isOnboardingCompleted = appPreferences.isOnboardingCompleted()
                state.themeRaw = resolvedThemeRaw()

                if isOnboardingCompleted, state.home != nil {
                    return .none
                }
                if !isOnboardingCompleted, state.onboarding != nil {
                    return .none
                }

                if isOnboardingCompleted {
                    state.home = HomeFeature.State()
                    state.onboarding = nil
                    return .run { [reminderSchedulingUseCase] _ in
                        await reminderSchedulingUseCase.resyncRepresentativeReminder()
                    }
                } else {
                    state.onboarding = WalkThroughFeature.State(fromSetting: false)
                    state.home = nil
                    return .none
                }

            case .themePreferenceRefreshRequested:
                state.themeRaw = resolvedThemeRaw()
                return .none

            case let .scenePhaseChanged(phase):
                guard phase == .active, state.home != nil else { return .none }
                return .run { [reminderSchedulingUseCase] _ in
                    await reminderSchedulingUseCase.resyncRepresentativeReminder()
                }

            case .onboarding(.delegate(.completeOnboarding)):
                appPreferences.setOnboardingCompleted(true)
                state.home = HomeFeature.State()
                state.onboarding = nil
                state.themeRaw = resolvedThemeRaw()
                return .run { [reminderSchedulingUseCase] _ in
                    await reminderSchedulingUseCase.resyncRepresentativeReminder()
                }
                
            case .onboarding, .home:
                return .none
            }
        }
        .ifLet(\.onboarding, action: \.onboarding) {
            WalkThroughFeature()
        }
        .ifLet(\.home, action: \.home) {
            HomeFeature()
        }
    }
}
