import Foundation
import Testing
import ComposableArchitecture
import JacsimClient
import Ports

@testable import Jacsim

private actor GlobalNotificationSettingRecorder {
    private(set) var values: [Bool] = []
    private let outcome: GlobalNotificationSettingUseCase.Outcome

    init(outcome: GlobalNotificationSettingUseCase.Outcome) {
        self.outcome = outcome
    }

    func setEnabled(_ isEnabled: Bool) -> GlobalNotificationSettingUseCase.Outcome {
        values.append(isEnabled)
        return outcome
    }

    func callCount() -> Int { values.count }
    func lastValue() -> Bool? { values.last }
}

@MainActor
@Test("loadNotificationSettings는 전역 설정값을 반영한다")
func settingFeatureLoadNotificationSettingsUsesGlobalToggle() async {
    let store = TestStore(initialState: SettingFeature.State()) {
        SettingFeature()
    } withDependencies: {
        $0.userSettingsRepository = UserSettingsRepositoryPort(
            isNotificationEnabled: { false },
            getAllReminders: { [] },
            updateNotificationEnabled: { _ in }
        )
    }

    await store.send(.loadNotificationSettings) {
        $0.isLoading = true
    }
    await store.receive(.notificationSettingsResponse(false)) {
        $0.isNotificationEnabled = false
        $0.isLoading = false
    }
}

@MainActor
@Test("알림 OFF 토글은 use case로 위임하고 OFF로 반영한다")
func settingFeatureToggleOffDelegatesToUseCase() async {
    let recorder = GlobalNotificationSettingRecorder(outcome: .disabled)

    var initialState = SettingFeature.State()
    initialState.isNotificationEnabled = true

    let store = TestStore(initialState: initialState) {
        SettingFeature()
    } withDependencies: {
        $0.globalNotificationSettingUseCase = GlobalNotificationSettingUseCase(
            setEnabled: { await recorder.setEnabled($0) }
        )
    }

    await store.send(.notificationToggleChanged(false)) {
        $0.isNotificationEnabled = false
        $0.isLoading = true
        $0.notificationBanner = nil
    }
    await store.receive(.notificationSettingsResponse(false)) {
        $0.isNotificationEnabled = false
        $0.isLoading = false
    }

    #expect(await recorder.callCount() == 1)
    #expect(await recorder.lastValue() == false)
}

@MainActor
@Test("알림 ON 토글 성공 시 ON으로 반영한다")
func settingFeatureToggleOnSuccess() async {
    let recorder = GlobalNotificationSettingRecorder(outcome: .enabled)

    let store = TestStore(initialState: SettingFeature.State()) {
        SettingFeature()
    } withDependencies: {
        $0.globalNotificationSettingUseCase = GlobalNotificationSettingUseCase(
            setEnabled: { await recorder.setEnabled($0) }
        )
    }

    await store.send(.notificationToggleChanged(true)) {
        $0.isNotificationEnabled = true
        $0.isLoading = true
        $0.notificationBanner = nil
    }
    await store.receive(.notificationSettingsResponse(true)) {
        $0.isNotificationEnabled = true
        $0.isLoading = false
    }

    #expect(await recorder.callCount() == 1)
    #expect(await recorder.lastValue() == true)
}

@MainActor
@Test("알림 ON 토글 시 권한 거부면 OFF로 복원하고 배너를 노출한다")
func settingFeatureToggleOnDeniedShowsPermissionBanner() async {
    let recorder = GlobalNotificationSettingRecorder(outcome: .permissionDenied)

    let store = TestStore(initialState: SettingFeature.State()) {
        SettingFeature()
    } withDependencies: {
        $0.globalNotificationSettingUseCase = GlobalNotificationSettingUseCase(
            setEnabled: { await recorder.setEnabled($0) }
        )
    }

    await store.send(.notificationToggleChanged(true)) {
        $0.isNotificationEnabled = true
        $0.isLoading = true
        $0.notificationBanner = nil
    }
    await store.receive(.notificationSettingsResponse(false)) {
        $0.isNotificationEnabled = false
        $0.isLoading = false
    }
    await store.receive(.notificationPermissionDenied) {
        $0.notificationBanner = .permissionDenied
    }

    #expect(await recorder.callCount() == 1)
    #expect(await recorder.lastValue() == true)
}

@MainActor
@Test("알림 ON 토글 시 권한 요청 오류면 오류 배너를 노출한다")
func settingFeatureToggleOnPermissionErrorShowsErrorBanner() async {
    let recorder = GlobalNotificationSettingRecorder(outcome: .permissionError)

    let store = TestStore(initialState: SettingFeature.State()) {
        SettingFeature()
    } withDependencies: {
        $0.globalNotificationSettingUseCase = GlobalNotificationSettingUseCase(
            setEnabled: { await recorder.setEnabled($0) }
        )
    }

    await store.send(.notificationToggleChanged(true)) {
        $0.isNotificationEnabled = true
        $0.isLoading = true
        $0.notificationBanner = nil
    }
    await store.receive(.notificationSettingsResponse(false)) {
        $0.isNotificationEnabled = false
        $0.isLoading = false
    }
    await store.receive(.notificationPermissionError) {
        $0.notificationBanner = .permissionError
    }

    #expect(await recorder.callCount() == 1)
    #expect(await recorder.lastValue() == true)
}

@MainActor
@Test("테마 변경은 설정 상태와 앱 환경설정을 함께 갱신한다")
func settingFeatureThemeChangePersistsThemeMode() async {
    let appPreferences = AppPreferencesPort.inMemory()

    let store = TestStore(initialState: SettingFeature.State()) {
        SettingFeature()
    } withDependencies: {
        $0.appPreferences = appPreferences
    }

    await store.send(.themeChanged(.dark)) {
        $0.theme = .dark
    }

    #expect(appPreferences.getThemeModeRaw() == ThemeMode.dark.rawValue)
}

@MainActor
@Test("사용법 액션은 온보딩 안내 delegate를 보낸다")
func settingFeatureUseCaseActionSendsWalkthroughDelegate() async {
    let store = TestStore(initialState: SettingFeature.State()) {
        SettingFeature()
    }

    await store.send(.useCaseButtonTapped)
    await store.receive(.delegate(.navigateToWalkThrough))
}

@MainActor
@Test("문의하기 액션은 메일 작성 delegate를 보낸다")
func settingFeatureInquiryActionSendsMailDelegate() async {
    let store = TestStore(initialState: SettingFeature.State()) {
        SettingFeature()
    }

    await store.send(.inquiryButtonTapped)
    await store.receive(.delegate(.presentMailCompose))
}

@MainActor
@Test("리뷰 액션은 리뷰 요청 delegate를 보낸다")
func settingFeatureReviewActionSendsReviewDelegate() async {
    let store = TestStore(initialState: SettingFeature.State()) {
        SettingFeature()
    }

    await store.send(.reviewButtonTapped)
    await store.receive(.delegate(.openReviewURL))
}

@MainActor
@Test("배너 닫기 액션은 알림 배너를 제거한다")
func settingFeatureDismissBannerClearsNotificationBanner() async {
    var initialState = SettingFeature.State()
    initialState.notificationBanner = .permissionDenied

    let store = TestStore(initialState: initialState) {
        SettingFeature()
    }

    await store.send(.notificationBannerDismissed) {
        $0.notificationBanner = nil
    }
}
