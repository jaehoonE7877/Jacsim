import Foundation
import Testing
@testable import Domain

struct TaskUpdateUseCaseTests {
    
    @Test
    func testUpdateTaskInfo() async throws {
        var updatedTask: Task?
        let useCase = TaskUpdateUseCase(
            updateTask: { task in
                updatedTask = task
            }
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
        #expect(updatedTask?.title == "New Title")
    }
    
    @Test
    func testUpdateTaskInfoWithNoStage() async throws {
        let useCase = TaskUpdateUseCase(
            updateTask: { _ in }
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
        #expect(result.alarmDate == nil)
    }
}
