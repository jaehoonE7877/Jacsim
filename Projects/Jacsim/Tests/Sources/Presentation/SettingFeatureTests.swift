import Foundation
import Testing
import ComposableArchitecture
import Domain
import ExternalInterface

@testable import Jacsim

private actor NotificationSchedulerRecorder {
    private(set) var scheduledTaskIDs: [TaskID] = []
    private(set) var cancelledTaskIDs: [TaskID] = []

    func recordScheduled(_ taskID: TaskID) {
        scheduledTaskIDs.append(taskID)
    }

    func recordCancelled(_ taskID: TaskID) {
        cancelledTaskIDs.append(taskID)
    }

    func scheduledCount() -> Int { scheduledTaskIDs.count }
    func cancelledCount() -> Int { cancelledTaskIDs.count }
}

private actor UserSettingsRecorder {
    private(set) var globalNotificationEnabled: Bool
    private(set) var reminders: [ReminderInfo]
    private(set) var updatedValues: [Bool] = []

    init(globalNotificationEnabled: Bool, reminders: [ReminderInfo]) {
        self.globalNotificationEnabled = globalNotificationEnabled
        self.reminders = reminders
    }

    func isNotificationEnabled() -> Bool {
        globalNotificationEnabled
    }

    func getAllReminders() -> [ReminderInfo] {
        reminders
    }

    func updateNotificationEnabled(_ enabled: Bool) {
        updatedValues.append(enabled)
        globalNotificationEnabled = enabled

        // Simulate previously buggy persistence behavior where reminders disappeared on OFF.
        if !enabled {
            reminders = []
        }
    }

    func lastUpdatedValue() -> Bool? {
        updatedValues.last
    }
}

private enum PermissionRequestError: Error {
    case failed
}

@MainActor
@Test("loadNotificationSettings는 전역 설정값을 반영한다")
func settingFeatureLoadNotificationSettingsUsesGlobalToggle() async {
    let userSettings = UserSettingsRecorder(globalNotificationEnabled: false, reminders: [])
    let scheduler = NotificationSchedulerRecorder()

    let store = TestStore(initialState: SettingFeature.State()) {
        SettingFeature()
    } withDependencies: {
        $0.userSettingsRepository = UserSettingsRepositoryPort(
            isNotificationEnabled: { await userSettings.isNotificationEnabled() },
            getAllReminders: { await userSettings.getAllReminders() },
            updateNotificationEnabled: { await userSettings.updateNotificationEnabled($0) }
        )
        $0.notificationScheduler = NotificationSchedulerPort(
            scheduleDailyReminder: { taskID, _, _ in await scheduler.recordScheduled(taskID) },
            cancelReminder: { taskID in await scheduler.recordCancelled(taskID) },
            cancelAllReminders: {},
            requestAuthorization: { true }
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
@Test("알림 OFF 토글 시 reminder 목록이 비워져도 cancel이 수행된다")
func settingFeatureToggleOffCancelsAllFetchedReminders() async {
    let reminders: [ReminderInfo] = [
        ReminderInfo(taskId: TaskID(UUID()), title: "A", time: DateComponents(hour: 21, minute: 0)),
        ReminderInfo(taskId: TaskID(UUID()), title: "B", time: DateComponents(hour: 22, minute: 30))
    ]
    let userSettings = UserSettingsRecorder(globalNotificationEnabled: true, reminders: reminders)
    let scheduler = NotificationSchedulerRecorder()

    var initialState = SettingFeature.State()
    initialState.isNotificationEnabled = true

    let store = TestStore(initialState: initialState) {
        SettingFeature()
    } withDependencies: {
        $0.userSettingsRepository = UserSettingsRepositoryPort(
            isNotificationEnabled: { await userSettings.isNotificationEnabled() },
            getAllReminders: { await userSettings.getAllReminders() },
            updateNotificationEnabled: { await userSettings.updateNotificationEnabled($0) }
        )
        $0.notificationScheduler = NotificationSchedulerPort(
            scheduleDailyReminder: { taskID, _, _ in await scheduler.recordScheduled(taskID) },
            cancelReminder: { taskID in await scheduler.recordCancelled(taskID) },
            cancelAllReminders: {},
            requestAuthorization: { true }
        )
    }

    await store.send(.notificationToggleChanged(false)) {
        $0.isNotificationEnabled = false
        $0.isLoading = true
    }
    await store.receive(.notificationSettingsResponse(false)) {
        $0.isNotificationEnabled = false
        $0.isLoading = false
    }

    #expect(await scheduler.cancelledCount() == 2)
    #expect(await scheduler.scheduledCount() == 0)
    #expect(await userSettings.lastUpdatedValue() == false)
}

@MainActor
@Test("알림 ON 토글 시 alarm이 있는 reminder를 모두 재등록한다")
func settingFeatureToggleOnSchedulesAllReminders() async {
    let reminders: [ReminderInfo] = [
        ReminderInfo(taskId: TaskID(UUID()), title: "A", time: DateComponents(hour: 7, minute: 45)),
        ReminderInfo(taskId: TaskID(UUID()), title: "B", time: DateComponents(hour: 20, minute: 15))
    ]
    let userSettings = UserSettingsRecorder(globalNotificationEnabled: false, reminders: reminders)
    let scheduler = NotificationSchedulerRecorder()

    let store = TestStore(initialState: SettingFeature.State()) {
        SettingFeature()
    } withDependencies: {
        $0.userSettingsRepository = UserSettingsRepositoryPort(
            isNotificationEnabled: { await userSettings.isNotificationEnabled() },
            getAllReminders: { await userSettings.getAllReminders() },
            updateNotificationEnabled: { await userSettings.updateNotificationEnabled($0) }
        )
        $0.notificationScheduler = NotificationSchedulerPort(
            scheduleDailyReminder: { taskID, _, _ in await scheduler.recordScheduled(taskID) },
            cancelReminder: { taskID in await scheduler.recordCancelled(taskID) },
            cancelAllReminders: {},
            requestAuthorization: { true }
        )
    }

    await store.send(.notificationToggleChanged(true)) {
        $0.isNotificationEnabled = true
        $0.isLoading = true
    }
    await store.receive(.notificationSettingsResponse(true)) {
        $0.isNotificationEnabled = true
        $0.isLoading = false
    }

    #expect(await scheduler.scheduledCount() == 2)
    #expect(await scheduler.cancelledCount() == 0)
    #expect(await userSettings.lastUpdatedValue() == true)
}

@MainActor
@Test("알림 ON 토글 시 권한 거부면 OFF로 복원하고 배너를 노출한다")
func settingFeatureToggleOnDeniedShowsPermissionBanner() async {
    let reminders: [ReminderInfo] = [
        ReminderInfo(taskId: TaskID(UUID()), title: "A", time: DateComponents(hour: 9, minute: 0))
    ]
    let userSettings = UserSettingsRecorder(globalNotificationEnabled: false, reminders: reminders)
    let scheduler = NotificationSchedulerRecorder()

    let store = TestStore(initialState: SettingFeature.State()) {
        SettingFeature()
    } withDependencies: {
        $0.userSettingsRepository = UserSettingsRepositoryPort(
            isNotificationEnabled: { await userSettings.isNotificationEnabled() },
            getAllReminders: { await userSettings.getAllReminders() },
            updateNotificationEnabled: { await userSettings.updateNotificationEnabled($0) }
        )
        $0.notificationScheduler = NotificationSchedulerPort(
            scheduleDailyReminder: { taskID, _, _ in await scheduler.recordScheduled(taskID) },
            cancelReminder: { taskID in await scheduler.recordCancelled(taskID) },
            cancelAllReminders: {},
            requestAuthorization: { false }
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

    #expect(await scheduler.scheduledCount() == 0)
    #expect(await scheduler.cancelledCount() == 0)
    #expect(await userSettings.lastUpdatedValue() == nil)
}

@MainActor
@Test("알림 ON 토글 시 권한 요청 오류면 오류 배너를 노출한다")
func settingFeatureToggleOnPermissionErrorShowsErrorBanner() async {
    let reminders: [ReminderInfo] = [
        ReminderInfo(taskId: TaskID(UUID()), title: "A", time: DateComponents(hour: 9, minute: 0))
    ]
    let userSettings = UserSettingsRecorder(globalNotificationEnabled: false, reminders: reminders)
    let scheduler = NotificationSchedulerRecorder()

    let store = TestStore(initialState: SettingFeature.State()) {
        SettingFeature()
    } withDependencies: {
        $0.userSettingsRepository = UserSettingsRepositoryPort(
            isNotificationEnabled: { await userSettings.isNotificationEnabled() },
            getAllReminders: { await userSettings.getAllReminders() },
            updateNotificationEnabled: { await userSettings.updateNotificationEnabled($0) }
        )
        $0.notificationScheduler = NotificationSchedulerPort(
            scheduleDailyReminder: { taskID, _, _ in await scheduler.recordScheduled(taskID) },
            cancelReminder: { taskID in await scheduler.recordCancelled(taskID) },
            cancelAllReminders: {},
            requestAuthorization: { throw PermissionRequestError.failed }
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

    #expect(await scheduler.scheduledCount() == 0)
    #expect(await scheduler.cancelledCount() == 0)
    #expect(await userSettings.lastUpdatedValue() == nil)
}
