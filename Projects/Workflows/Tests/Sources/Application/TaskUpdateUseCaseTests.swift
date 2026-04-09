import Foundation
import Testing
import Domain
import Ports

@testable import Workflows

struct TaskUpdateUseCaseTests {
    @Test
    func testUpdateTaskInfo() async throws {
        let store = MockTaskStore()
        let repository = makeRepositoryPort(store: store)
        let useCase = TaskUpdateUseCase(taskRepository: repository)

        let originalStage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: 7,
            startDate: Date(),
            endDate: Date(),
            durationDays: 7,
            successDays: 0,
            resultRaw: StageResult.inProgress.rawValue
        )

        let task = Task(
            id: TaskID(UUID()),
            title: "Original Title",
            startDate: Date(),
            endDate: Date(),
            stages: [originalStage],
            records: []
        )

        let result = try await useCase.updateTaskInfo(
            task: task,
            title: "New Title",
            durationDays: 14,
            isNotificationEnabled: true,
            alarmDate: .now
        )

        #expect(result.title == "New Title")
        #expect(result.stages.last?.durationDays == 14)
        #expect(result.isNotificationEnabled == true)
        let updatedTask = await store.fetchUpdatedTask()
        #expect(updatedTask?.title == "New Title")
    }

    @Test
    func testUpdateTaskInfoWithNoStage() async throws {
        let store = MockTaskStore()
        let repository = makeRepositoryPort(store: store)
        let useCase = TaskUpdateUseCase(taskRepository: repository)

        let task = Task(
            id: TaskID(UUID()),
            title: "Original Title",
            startDate: Date(),
            endDate: Date(),
            stages: [],
            records: []
        )

        let result = try await useCase.updateTaskInfo(
            task: task,
            title: "New Title",
            durationDays: 14,
            isNotificationEnabled: false,
            alarmDate: .now
        )

        #expect(result.title == "New Title")
        #expect(result.stages.isEmpty)
        #expect(result.isNotificationEnabled == false)
        #expect(result.alarm == nil)
    }
}

private actor MockTaskStore {
    private var updatedTask: Task?

    func updateTask(_ task: Task) {
        updatedTask = task
    }

    func fetchUpdatedTask() -> Task? {
        updatedTask
    }
}

private func makeRepositoryPort(store: MockTaskStore) -> TaskRepositoryPort {
    TaskRepositoryPort(
        fetchActiveTasks: { [] },
        fetchTask: { _ in nil },
        addTask: { _ in },
        updateTask: { task in await store.updateTask(task) },
        deleteTask: { _ in },
        fetchTasksByStatus: { _ in [] }
    )
}
