import Foundation
import Testing
@testable import Domain

struct TaskUpdateUseCaseTests {
    
    @Test
    func testUpdateTaskInfo() async throws {
        let store = MockTaskStore()
        let useCase = TaskUpdateUseCase(
            updateTask: { try await store.updateTask($0) }
        )
        
        let originalStage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: 7,
            startDate: Date(),
            endDate: Date(),
            durationDays: 7,
            successDays: 0,
            resultRaw: "inProgress"
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
        let updatedTask = try await store.fetchUpdatedTask()
        #expect(updatedTask?.title == "New Title")
    }
    
    @Test
    func testUpdateTaskInfoWithNoStage() async throws {
        let store = MockTaskStore()
        let useCase = TaskUpdateUseCase(
            updateTask: { try await store.updateTask($0) }
        )
        
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

    func updateTask(_ task: Task) throws {
        updatedTask = task
    }

    func fetchUpdatedTask() throws -> Task? {
        updatedTask
    }
}
