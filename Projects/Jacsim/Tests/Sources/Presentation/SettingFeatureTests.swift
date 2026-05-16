import Domain
import ExternalInterface
import Foundation
import Testing

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

@MainActor
@Test("설정 상태는 앱 버전 표시값을 주입받을 수 있다")
func settingFeatureStateUsesInjectedVersion() {
    let model = SettingScreenModel(dependencies: .test, version: "2.0.0")

    #expect(model.version == "2.0.0")
}

@MainActor
@Test("loadNotificationSettings는 전역 설정값을 반영한다")
func settingFeatureLoadNotificationSettingsUsesGlobalToggle() async {
    let userSettings = UserSettingsRecorder(globalNotificationEnabled: false, reminders: [])
    let scheduler = NotificationSchedulerRecorder()
    let model = SettingScreenModel(
        dependencies: makeSettingDependencies(userSettings: userSettings, scheduler: scheduler)
    )

    model.loadNotificationSettings()

    await waitUntil { model.isLoading == false }
    #expect(model.isNotificationEnabled == false)
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
    let model = SettingScreenModel(
        dependencies: makeSettingDependencies(userSettings: userSettings, scheduler: scheduler)
    )
    model.isNotificationEnabled = true

    model.notificationToggleChanged(false)

    await waitUntil { model.isLoading == false }
    #expect(model.isNotificationEnabled == false)
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
    let model = SettingScreenModel(
        dependencies: makeSettingDependencies(userSettings: userSettings, scheduler: scheduler)
    )

    model.notificationToggleChanged(true)

    await waitUntil { model.isLoading == false }
    #expect(model.isNotificationEnabled)
    #expect(await scheduler.scheduledCount() == 2)
    #expect(await scheduler.cancelledCount() == 0)
    #expect(await userSettings.lastUpdatedValue() == true)
}

@MainActor
@Test("알림 ON 토글 시 시스템 권한이 거부되면 전역 알림을 다시 끄고 안내 상태로 전환한다")
func settingFeatureToggleOnHandlesPermissionDenied() async {
    let reminders: [ReminderInfo] = [
        ReminderInfo(taskId: TaskID(UUID()), title: "A", time: DateComponents(hour: 7, minute: 45))
    ]
    let userSettings = UserSettingsRecorder(globalNotificationEnabled: false, reminders: reminders)
    let scheduler = NotificationSchedulerRecorder()
    let model = SettingScreenModel(
        dependencies: makeSettingDependencies(
            userSettings: userSettings,
            scheduler: scheduler,
            requestAuthorization: { false }
        )
    )

    model.notificationToggleChanged(true)

    await waitUntil { model.isLoading == false }
    #expect(model.isNotificationEnabled == false)
    #expect(model.notificationPermissionDenied)
    #expect(await scheduler.scheduledCount() == 0)
    #expect(await userSettings.lastUpdatedValue() == false)
}

private func makeSettingDependencies(
    userSettings: UserSettingsRecorder,
    scheduler: NotificationSchedulerRecorder,
    requestAuthorization: @escaping @Sendable () async throws -> Bool = { true }
) -> JacsimDependencies {
    var dependencies = JacsimDependencies.test
    dependencies.userSettingsRepository = UserSettingsRepositoryPort(
        isNotificationEnabled: { await userSettings.isNotificationEnabled() },
        getAllReminders: { await userSettings.getAllReminders() },
        updateNotificationEnabled: { await userSettings.updateNotificationEnabled($0) }
    )
    dependencies.notificationScheduler = NotificationSchedulerPort(
        scheduleDailyReminder: { taskID, _, _ in await scheduler.recordScheduled(taskID) },
        cancelReminder: { taskID in await scheduler.recordCancelled(taskID) },
        cancelAllReminders: {},
        requestAuthorization: requestAuthorization
    )
    return dependencies
}

@MainActor
private func waitUntil(
    timeoutIterations: Int = 50,
    condition: @escaping @MainActor () async -> Bool
) async {
    for _ in 0..<timeoutIterations {
        if await condition() { return }
        try? await _Concurrency.Task.sleep(nanoseconds: 20_000_000)
    }
}
