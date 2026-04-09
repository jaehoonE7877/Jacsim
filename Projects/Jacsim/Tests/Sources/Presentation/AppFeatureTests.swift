import Testing
import ComposableArchitecture
import Domain
import Ports
import JacsimClient
import SwiftUI

@testable import Jacsim

private actor ReminderSchedulingRecorder {
    private(set) var syncCount = 0

    func markSync() {
        syncCount += 1
    }
}

@MainActor
@Test("onAppear 시 온보딩 완료 사용자는 home으로 라우팅된다")
func appFeatureRoutesToHomeOnAppearWhenOnboardingCompleted() async {
    let appPreferences = AppPreferencesPort.inMemory()
    appPreferences.setOnboardingCompleted(true)
    let recorder = ReminderSchedulingRecorder()

    let store = TestStore(initialState: AppFeature.State()) {
        AppFeature()
    } withDependencies: {
        $0.appPreferences = appPreferences
        $0.reminderSchedulingUseCase = ReminderSchedulingUseCase(
            notificationScheduler: .init(
                scheduleReminder: { _ in },
                cancelReminder: { _ in },
                cancelAllReminders: { await recorder.markSync() },
                requestAuthorization: { false }
            ),
            userSettingsRepository: .init(
                isNotificationEnabled: { false },
                getAllReminders: { [] },
                updateNotificationEnabled: { _ in }
            ),
            taskRepository: .init(
                fetchActiveTasks: { [] },
                fetchTask: { _ in nil },
                addTask: { _ in },
                updateTask: { _ in },
                deleteTask: { _ in },
                fetchTasksByStatus: { _ in [] }
            ),
            activeTaskService: ActiveTaskService()
        )
    }
    store.exhaustivity = .off

    await store.send(.onAppear)
    #expect(
        ifCaseHome(store.state)
    )
    #expect(await recorder.syncCount == 1)
}

@MainActor
@Test("온보딩 완료 액션은 home 전환과 완료 플래그 저장을 수행한다")
func appFeatureCompleteOnboardingUpdatesStateAndPreference() async {
    let appPreferences = AppPreferencesPort.inMemory()

    let store = TestStore(initialState: AppFeature.State()) {
        AppFeature()
    } withDependencies: {
        $0.appPreferences = appPreferences
    }
    store.exhaustivity = .off

    await store.send(.onboarding(.delegate(.completeOnboarding)))

    #expect(ifCaseHome(store.state))
    #expect(appPreferences.isOnboardingCompleted())
}

@MainActor
@Test("scenePhase active 시 reminder schedule을 다시 동기화한다")
func appFeatureResyncsReminderWhenSceneBecomesActive() async {
    let recorder = ReminderSchedulingRecorder()
    var initialState = AppFeature.State()
    initialState.home = HomeFeature.State()
    initialState.onboarding = nil

    let store = TestStore(initialState: initialState) {
        AppFeature()
    } withDependencies: {
        $0.reminderSchedulingUseCase = ReminderSchedulingUseCase(
            notificationScheduler: .init(
                scheduleReminder: { _ in },
                cancelReminder: { _ in },
                cancelAllReminders: { await recorder.markSync() },
                requestAuthorization: { false }
            ),
            userSettingsRepository: .init(
                isNotificationEnabled: { false },
                getAllReminders: { [] },
                updateNotificationEnabled: { _ in }
            ),
            taskRepository: .init(
                fetchActiveTasks: { [] },
                fetchTask: { _ in nil },
                addTask: { _ in },
                updateTask: { _ in },
                deleteTask: { _ in },
                fetchTasksByStatus: { _ in [] }
            ),
            activeTaskService: ActiveTaskService()
        )
    }
    store.exhaustivity = .off

    await store.send(.scenePhaseChanged(.active))
    #expect(await recorder.syncCount == 1)
}

private func ifCaseHome(_ state: AppFeature.State) -> Bool {
    state.home != nil
}
