import Domain
import ExternalInterface
import Foundation
import Testing

@testable import Jacsim

private actor AppNotificationSchedulerRecorder {
    private(set) var scheduledTaskIDs: [TaskID] = []
    private(set) var cancelledTaskIDs: [TaskID] = []

    func recordScheduled(_ taskID: TaskID) {
        scheduledTaskIDs.append(taskID)
    }

    func recordCancelled(_ taskID: TaskID) {
        cancelledTaskIDs.append(taskID)
    }

    func scheduledIDs() -> [TaskID] { scheduledTaskIDs }
    func cancelledIDs() -> [TaskID] { cancelledTaskIDs }
}

@MainActor
@Test("앱 활성화는 대표 reminder 1건만 예약하고 나머지는 stale reminder로 정리한다")
func appFeatureActiveSyncSchedulesOnlyRepresentativeReminder() async {
    let focusTaskID = TaskID(UUID())
    let staleTaskID = TaskID(UUID())
    let recorder = AppNotificationSchedulerRecorder()
    var dependencies = JacsimDependencies.test
    dependencies.appPreferences = .inMemory()
    dependencies.userSettingsRepository = UserSettingsRepositoryPort(
        isNotificationEnabled: { true },
        getAllReminders: {
            [
                ReminderInfo(
                    taskId: focusTaskID,
                    title: "대표 작심",
                    time: DateComponents(year: 2026, month: 5, day: 2, hour: 21, minute: 0)
                ),
                ReminderInfo(
                    taskId: staleTaskID,
                    title: "비대표 작심",
                    time: DateComponents(hour: 22, minute: 0),
                    shouldSchedule: false
                )
            ]
        },
        updateNotificationEnabled: { _ in }
    )
    dependencies.notificationScheduler = NotificationSchedulerPort(
        scheduleDailyReminder: { taskID, _, _ in await recorder.recordScheduled(taskID) },
        cancelReminder: { taskID in await recorder.recordCancelled(taskID) },
        cancelAllReminders: {},
        requestAuthorization: { true }
    )
    let model = AppModel(dependencies: dependencies)

    model.appBecameActive()

    await waitUntil {
        await recorder.scheduledIDs() == [focusTaskID]
    }
    #expect(await recorder.scheduledIDs() == [focusTaskID])
    #expect(await recorder.cancelledIDs() == [staleTaskID])
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
