import Foundation
import Testing
import ComposableArchitecture
import Domain
import ExternalInterface

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

    let store = TestStore(initialState: AppFeature.State()) {
        AppFeature()
    } withDependencies: {
        $0.appPreferences = .inMemory()
        $0.userSettingsRepository = UserSettingsRepositoryPort(
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
        $0.notificationScheduler = NotificationSchedulerPort(
            scheduleDailyReminder: { taskID, _, _ in await recorder.recordScheduled(taskID) },
            cancelReminder: { taskID in await recorder.recordCancelled(taskID) },
            cancelAllReminders: {},
            requestAuthorization: { true }
        )
    }
    store.exhaustivity = .off

    await store.send(.appBecameActive)
    await store.finish()

    #expect(await recorder.scheduledIDs() == [focusTaskID])
    #expect(await recorder.cancelledIDs() == [staleTaskID])
}
