import Testing
import ComposableArchitecture
import ExternalInterface

@testable import Jacsim

@MainActor
@Test("onAppear 시 온보딩 완료 사용자는 main으로 라우팅된다")
func appFeatureRoutesToMainOnAppearWhenOnboardingCompleted() async {
    let appPreferences = AppPreferencesPort.inMemory()
    appPreferences.setOnboardingCompleted(true)

    let store = TestStore(initialState: AppFeature.State()) {
        AppFeature()
    } withDependencies: {
        $0.appPreferences = appPreferences
    }
    store.exhaustivity = .off

    await store.send(.onAppear)
    #expect(
        ifCaseMain(store.state)
    )
}

@MainActor
@Test("온보딩 완료 액션은 main 전환과 완료 플래그 저장을 수행한다")
func appFeatureCompleteOnboardingUpdatesStateAndPreference() async {
    let appPreferences = AppPreferencesPort.inMemory()

    let store = TestStore(initialState: AppFeature.State()) {
        AppFeature()
    } withDependencies: {
        $0.appPreferences = appPreferences
    }
    store.exhaustivity = .off

    await store.send(.onboarding(.delegate(.completeOnboarding)))

    #expect(ifCaseMain(store.state))
    #expect(appPreferences.isOnboardingCompleted())
}

private func ifCaseMain(_ state: AppFeature.State) -> Bool {
    if case .main = state {
        return true
    }
    return false
}
