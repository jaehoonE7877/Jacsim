import Foundation
import Testing
import Domain
import Ports

@testable import Workflows

struct IntegrityWorkflowTests {
    @Test
    func certifyTaskTodayUseCaseRestoresPreviousImageWhenTaskUpdateFails() async throws {
        let imageStore = ImageStoreSpy()
        let task = makeTaskWithSingleRecord()
        let imageKey = try #require(task.imageKey(for: 0))
        let originalImage = Data([0x01, 0x02, 0x03])
        let replacementImage = Data([0x09, 0x08, 0x07])
        await imageStore.seed(key: imageKey, data: originalImage)

        let repository = TaskRepositoryPort(
            fetchActiveTasks: { [] },
            fetchTask: { _ in task },
            addTask: { _ in },
            updateTask: { _ in throw WorkflowFailure.failed },
            deleteTask: { _ in },
            fetchTasksByStatus: { _ in [] }
        )
        let useCase = CertifyTaskTodayUseCase.live(
            taskRepository: repository,
            imageStore: makeImageStorePort(spy: imageStore),
            reminderSchedulingUseCase: makeReminderSchedulingUseCase()
        )

        do {
            try await useCase.execute(
                .init(task: task, index: 0, memo: "memo", imageData: replacementImage)
            )
            Issue.record("Expected task update failure")
        } catch WorkflowFailure.failed {
            let restoredImage = await imageStore.load(key: imageKey)
            #expect(restoredImage == originalImage)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test
    func updateTaskSettingsUseCaseRestoresPreviousCoverImageWhenMetadataSaveFails() async throws {
        let imageStore = ImageStoreSpy()
        let task = makeTaskWithSingleRecord()
        let originalImage = Data([0xAA, 0xBB, 0xCC])
        let replacementImage = Data([0x10, 0x20, 0x30])
        await imageStore.seed(key: task.mainImageKey, data: originalImage)

        let repository = TaskRepositoryPort(
            fetchActiveTasks: { [] },
            fetchTask: { _ in task },
            addTask: { _ in },
            updateTask: { _ in throw WorkflowFailure.failed },
            deleteTask: { _ in },
            fetchTasksByStatus: { _ in [] }
        )
        let useCase = UpdateTaskSettingsUseCase.live(
            taskRepository: repository,
            imageStore: makeImageStorePort(spy: imageStore),
            reminderSchedulingUseCase: makeReminderSchedulingUseCase()
        )

        do {
            try await useCase.execute(
                .init(
                    task: task,
                    title: "updated",
                    durationDays: 7,
                    isAlarmEnabled: true,
                    alarmDate: Date(),
                    mainImageData: replacementImage
                )
            )
            Issue.record("Expected metadata save failure")
        } catch WorkflowFailure.failed {
            let restoredImage = await imageStore.load(key: task.mainImageKey)
            #expect(restoredImage == originalImage)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test
    func createNewTaskUseCasePersistsNormalizedInitialStage() async throws {
        let taskStore = CreatedTaskStore()
        let useCase = CreateNewTaskUseCase.live(
            taskRepository: TaskRepositoryPort(
                fetchActiveTasks: { [] },
                fetchTask: { _ in nil },
                addTask: { task in await taskStore.set(task) },
                updateTask: { _ in },
                deleteTask: { _ in },
                fetchTasksByStatus: { _ in [] }
            ),
            imageStore: makeImageStorePort(spy: ImageStoreSpy()),
            reminderSchedulingUseCase: makeReminderSchedulingUseCase(),
            now: { fixedDate(year: 2026, month: 3, day: 20, hour: 9) }
        )

        let createdTask = try await useCase.execute(
            .init(
                title: "새 작심",
                stageType: .seven,
                isAlarmEnabled: false,
                alarmDate: fixedDate(year: 2026, month: 3, day: 20, hour: 21),
                mainImageData: nil
            )
        )

        let persistedTask = try #require(await taskStore.get())
        #expect(createdTask.stages.last?.successDays == 0)
        #expect(createdTask.stages.last?.result == .inProgress)
        #expect(persistedTask.stages.last?.successDays == 0)
        #expect(persistedTask.stages.last?.result == .inProgress)
    }

    private func makeReminderSchedulingUseCase() -> ReminderSchedulingUseCase {
        ReminderSchedulingUseCase(
            notificationScheduler: NotificationSchedulerPort(
                scheduleReminder: { _ in },
                cancelReminder: { _ in },
                cancelAllReminders: {},
                requestAuthorization: { true }
            ),
            userSettingsRepository: UserSettingsRepositoryPort(
                isNotificationEnabled: { false },
                getAllReminders: { [] },
                updateNotificationEnabled: { _ in }
            ),
            taskRepository: TaskRepositoryPort(
                fetchActiveTasks: { [] },
                fetchTask: { _ in nil },
                addTask: { _ in },
                updateTask: { _ in },
                deleteTask: { _ in },
                fetchTasksByStatus: { _ in [] }
            )
        )
    }

    private func makeImageStorePort(spy: ImageStoreSpy) -> ImageStorePort {
        ImageStorePort(
            saveImage: { key, data in
                try await spy.save(key: key, data: data)
            },
            loadImage: { key in
                await spy.load(key: key)
            },
            deleteImage: { key in
                await spy.delete(key: key)
            },
            imageExists: { key in
                await spy.exists(key: key)
            }
        )
    }

    private func makeTaskWithSingleRecord() -> Task {
        let day = fixedDate(year: 2026, month: 3, day: 20)
        return Task(
            id: TaskID(UUID()),
            title: "작심",
            startDate: day,
            endDate: day,
            stages: [
                StageSnapshot(
                    id: UUID(),
                    stageTypeRaw: StageType.three.rawValue,
                    startDate: day,
                    endDate: day,
                    durationDays: 3,
                    successDays: 0,
                    resultRaw: StageResult.inProgress.rawValue
                )
            ],
            records: [
                DailyRecordSnapshot(id: UUID(), memo: "", check: false, date: day, imagePath: nil)
            ]
        )
    }

    private func fixedDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0
    ) -> Date {
        var components = DateComponents()
        components.calendar = Calendar.current
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return components.date ?? .distantPast
    }
}

private actor ImageStoreSpy {
    private var storage: [String: Data] = [:]

    func seed(key: String, data: Data) {
        storage[key] = data
    }

    func save(key: String, data: Data) throws -> String {
        storage[key] = data
        return key
    }

    func load(key: String) -> Data? {
        storage[key]
    }

    func delete(key: String) {
        storage.removeValue(forKey: key)
    }

    func exists(key: String) -> Bool {
        storage[key] != nil
    }
}

private actor CreatedTaskStore {
    private var task: Task?

    func set(_ task: Task) {
        self.task = task
    }

    func get() -> Task? {
        task
    }
}

private enum WorkflowFailure: Error {
    case failed
}
