import Foundation
import Testing
@testable import Domain

struct TaskUpdateUseCaseTests {
    
    @Test
    func testUpdateTaskInfo() async throws {
        let mockRepository = MockTaskRepository()
        let useCase = TaskUpdateUseCase(taskRepository: mockRepository)
        
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
            durationDays: 14
        )
        
        #expect(result.title == "New Title")
        #expect(result.stages.last?.durationDays == 14)
        #expect(mockRepository.updatedTask?.title == "New Title")
    }
    
    @Test
    func testUpdateTaskInfoWithNoStage() async throws {
        let mockRepository = MockTaskRepository()
        let useCase = TaskUpdateUseCase(taskRepository: mockRepository)
        
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
            durationDays: 14
        )
        
        #expect(result.title == "New Title")
        #expect(result.stages.isEmpty)
    }
}

private actor MockTaskRepository: TaskRepositoryPort {
    var updatedTask: Task?
    
    init() {
        super.init(
            fetchActiveTasks: { [] },
            fetchTask: { _ in nil },
            addTask: { _ in },
            updateTask: { [weak self] task in
                self?.updatedTask = task
            },
            deleteTask: { _ in },
            fetchTasksByStatus: { _ in [] }
        )
    }
}
