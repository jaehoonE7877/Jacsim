import Foundation
import Testing
import Domain
import Ports

@testable import Workflows

struct StageProgressionUseCaseTests {
    private let calendar = Calendar.current

    @Test
    func createNextStageExtendsTaskAndAppendsRecords() async throws {
        let store = MockTaskStore()
        let repository = makeRepositoryPort(store: store)
        let useCase = StageProgressionUseCase(taskRepository: repository)

        let baseStart = calendar.startOfDay(for: .now)
        let baseEnd = calendar.date(byAdding: .day, value: 2, to: baseStart)!
        let currentStage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: StageType.three.rawValue,
            startDate: baseStart,
            endDate: baseEnd,
            durationDays: 3,
            successDays: 2,
            resultRaw: StageResult.success.rawValue
        )
        let task = Task(
            id: TaskID(UUID()),
            title: "Stage Progress",
            startDate: baseStart,
            endDate: baseEnd,
            stages: [currentStage],
            records: makeRecords(startDate: baseStart, endDate: baseEnd)
        )

        await store.setTask(task)
        try await useCase.createNextStage(for: task.id)

        let updatedTask = await store.fetchTask(id: task.id)
        #expect(updatedTask != nil)
        #expect(updatedTask?.stages.count == 2)
        #expect(updatedTask?.stages.last?.stageType == .seven)
        #expect(updatedTask?.stages.last?.successDays == 0)
        #expect(updatedTask?.stages.last?.result == .inProgress)
        #expect(updatedTask?.endDate == updatedTask?.stages.last?.endDate)
        #expect(updatedTask?.records.count == 10)
    }

    @Test
    func createNextStageDoesNothingForFinalStage() async throws {
        let store = MockTaskStore()
        let repository = makeRepositoryPort(store: store)
        let useCase = StageProgressionUseCase(taskRepository: repository)

        let start = calendar.startOfDay(for: .now)
        let end = calendar.date(byAdding: .day, value: 29, to: start)!
        let finalStage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: StageType.thirty.rawValue,
            startDate: start,
            endDate: end,
            durationDays: 30,
            successDays: 20,
            resultRaw: StageResult.success.rawValue
        )
        let task = Task(
            id: TaskID(UUID()),
            title: "Final Stage",
            startDate: start,
            endDate: end,
            stages: [finalStage],
            records: makeRecords(startDate: start, endDate: end)
        )

        await store.setTask(task)
        try await useCase.createNextStage(for: task.id)

        let updatedTask = await store.fetchTask(id: task.id)
        #expect(updatedTask?.stages.count == 1)
        #expect(updatedTask?.records.count == 30)
    }

    @Test
    func resetStageRecordsRebuildsCurrentStageRange() async throws {
        let store = MockTaskStore()
        let repository = makeRepositoryPort(store: store)
        let useCase = StageProgressionUseCase(taskRepository: repository)

        let today = calendar.startOfDay(for: .now)
        let oldStart = calendar.date(byAdding: .day, value: -7, to: today)!
        let oldEnd = calendar.date(byAdding: .day, value: -1, to: today)!
        let currentStage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: StageType.seven.rawValue,
            startDate: oldStart,
            endDate: oldEnd,
            durationDays: 7,
            successDays: 2,
            resultRaw: StageResult.fail.rawValue
        )
        let preservedRecord = DailyRecordSnapshot(
            id: UUID(),
            memo: "old",
            check: true,
            date: oldStart,
            imagePath: nil
        )
        let staleTodayRecord = DailyRecordSnapshot(
            id: UUID(),
            memo: "today",
            check: true,
            date: today,
            imagePath: nil
        )
        let task = Task(
            id: TaskID(UUID()),
            title: "Retry Stage",
            startDate: oldStart,
            endDate: oldEnd,
            stages: [currentStage],
            records: [preservedRecord, staleTodayRecord]
        )

        await store.setTask(task)
        try await useCase.resetStageRecords(for: task.id)

        let updatedTask = await store.fetchTask(id: task.id)
        #expect(updatedTask != nil)
        #expect(updatedTask?.stages.count == 1)
        #expect(updatedTask?.stages.last?.startDate == today)
        #expect(updatedTask?.stages.last?.endDate == calendar.date(byAdding: .day, value: 6, to: today))
        #expect(updatedTask?.stages.last?.successDays == 0)
        #expect(updatedTask?.stages.last?.result == .inProgress)
        #expect(updatedTask?.endDate == updatedTask?.stages.last?.endDate)
        #expect(updatedTask?.records.count == 8)
        #expect(updatedTask?.records.first?.memo == "old")
    }

    private func makeRecords(startDate: Date, endDate: Date) -> [DailyRecordSnapshot] {
        var records: [DailyRecordSnapshot] = []
        var currentDate = calendar.startOfDay(for: startDate)
        let stageEndDate = calendar.startOfDay(for: endDate)

        while currentDate <= stageEndDate {
            records.append(
                DailyRecordSnapshot(
                    id: UUID(),
                    memo: "",
                    check: false,
                    date: currentDate,
                    imagePath: nil
                )
            )
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return records
    }
}

private actor MockTaskStore {
    private var tasks: [TaskID: Task] = [:]

    func setTask(_ task: Task) {
        tasks[task.id] = task
    }

    func fetchTask(id: TaskID) -> Task? {
        tasks[id]
    }

    func updateTask(_ task: Task) {
        tasks[task.id] = task
    }
}

private func makeRepositoryPort(store: MockTaskStore) -> TaskRepositoryPort {
    TaskRepositoryPort(
        fetchActiveTasks: { [] },
        fetchTask: { id in await store.fetchTask(id: id) },
        addTask: { _ in },
        updateTask: { task in await store.updateTask(task) },
        deleteTask: { _ in },
        fetchTasksByStatus: { _ in [] }
    )
}
