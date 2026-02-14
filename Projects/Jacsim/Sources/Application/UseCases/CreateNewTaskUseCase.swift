import Foundation
import Domain
import ExternalInterface

public struct CreateNewTaskUseCase: Sendable {
    public struct Input: Sendable, Equatable {
        public var title: String
        public var stageType: StageType
        public var isAlarmEnabled: Bool
        public var alarmDate: Date
        public var mainImageData: Data?

        public init(
            title: String,
            stageType: StageType,
            isAlarmEnabled: Bool,
            alarmDate: Date,
            mainImageData: Data?
        ) {
            self.title = title
            self.stageType = stageType
            self.isAlarmEnabled = isAlarmEnabled
            self.alarmDate = alarmDate
            self.mainImageData = mainImageData
        }
    }

    public var execute: @Sendable (Input) async throws -> Task

    public init(execute: @escaping @Sendable (Input) async throws -> Task) {
        self.execute = execute
    }
}

extension CreateNewTaskUseCase {
    static func live(
        taskRepository: TaskRepositoryPort,
        imageStore: ImageStorePort,
        reminderSchedulingUseCase: ReminderSchedulingUseCase,
        now: @escaping @Sendable () -> Date = { .now }
    ) -> Self {
        Self(
            execute: { input in
                let calendar = Calendar.current
                let startDate = calendar.startOfDay(for: now())
                let endDate = calendar.date(
                    byAdding: .day,
                    value: input.stageType.durationDays - 1,
                    to: startDate
                ) ?? startDate

                let taskId = TaskID(UUID())
                let stage = StageSnapshot(
                    id: UUID(),
                    stageTypeRaw: input.stageType.rawValue,
                    startDate: startDate,
                    endDate: endDate,
                    durationDays: input.stageType.durationDays,
                    successDays: 0,
                    resultRaw: StageResult.inProgress.rawValue
                )

                let records = makeRecords(startDate: startDate, endDate: endDate, calendar: calendar)

                var task = Task(
                    id: taskId,
                    title: input.title,
                    startDate: startDate,
                    endDate: endDate,
                    alarm: nil,
                    isNotificationEnabled: false,
                    stages: [stage],
                    records: records,
                    isDeleted: false,
                    createdAt: .now,
                    updatedAt: .now
                )

                task.isNotificationEnabled = input.isAlarmEnabled
                task.alarm = input.isAlarmEnabled ? input.alarmDate : nil

                if let data = input.mainImageData {
                    _ = try await imageStore.saveImage(task.mainImageKey, data)
                }

                try await taskRepository.addTask(task)

                await reminderSchedulingUseCase.scheduleReminderIfNeeded(
                    taskID: task.id,
                    title: task.title,
                    isAlarmEnabled: input.isAlarmEnabled,
                    alarmDate: input.alarmDate,
                    cancelExistingReminder: false
                )

                return task
            }
        )
    }

    private static func makeRecords(
        startDate: Date,
        endDate: Date,
        calendar: Calendar
    ) -> [DailyRecordSnapshot] {
        var records: [DailyRecordSnapshot] = []
        var currentDate = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)

        while currentDate <= end {
            records.append(
                DailyRecordSnapshot(
                    id: UUID(),
                    memo: "",
                    check: false,
                    date: currentDate,
                    imagePath: nil
                )
            )
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)
                ?? currentDate.addingTimeInterval(86400)
        }

        return records
    }
}
