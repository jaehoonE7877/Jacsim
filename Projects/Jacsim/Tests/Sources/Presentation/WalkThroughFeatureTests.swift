import Testing
import ComposableArchitecture

@testable import Jacsim

@MainActor
@Test("세 번째 페이지에서도 다음 페이지로 진행한다")
func walkthroughAdvancesFromThirdPage() async {
    var initialState = WalkThroughFeature.State(fromSetting: false)
    initialState.currentPage = 2

    let store = TestStore(initialState: initialState) {
        WalkThroughFeature()
    }

    await store.send(.continueButtonTapped) {
        $0.currentPage = 3
    }
}

@MainActor
@Test("마지막 페이지에서 계속하기는 온보딩 완료 delegate를 보낸다")
func walkthroughCompletesOnLastPage() async {
    var initialState = WalkThroughFeature.State(fromSetting: false)
    initialState.currentPage = 3

    let store = TestStore(initialState: initialState) {
        WalkThroughFeature()
    }

    await store.send(.continueButtonTapped)
    await store.receive(.delegate(.completeOnboarding))
}

@MainActor
@Test("건너뛰기 액션은 온보딩 완료 delegate를 보낸다")
func walkthroughSkipCompletesOnboarding() async {
    let store = TestStore(initialState: WalkThroughFeature.State(fromSetting: false)) {
        WalkThroughFeature()
    }

    await store.send(.skipButtonTapped)
    await store.receive(.delegate(.completeOnboarding))
}

@MainActor
@Test("설정에서 다시 본 온보딩도 마지막 전 단계까지 동일하게 진행할 수 있다")
func walkthroughFromSettingCanAdvancePages() async {
    let store = TestStore(initialState: WalkThroughFeature.State(fromSetting: true)) {
        WalkThroughFeature()
    }

    await store.send(.continueButtonTapped) {
        $0.currentPage = 1
    }
    await store.send(.continueButtonTapped) {
        $0.currentPage = 2
    }
    await store.send(.continueButtonTapped) {
        $0.currentPage = 3
    }

    #expect(store.state.fromSetting)
}
