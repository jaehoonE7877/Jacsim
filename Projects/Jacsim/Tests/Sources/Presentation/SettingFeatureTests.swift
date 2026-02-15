import Foundation
import Testing
import ComposableArchitecture
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
        $0.notificationSettingQueryUseCase = NotificationSettingQueryUseCase(
            isNotificationEnabled: { false }
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
