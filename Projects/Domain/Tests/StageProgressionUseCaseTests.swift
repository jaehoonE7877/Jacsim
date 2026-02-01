import Foundation
import Testing
@testable import Domain

struct StageProgressionUseCaseTests {
    
    @Test
    func testCreateNextStage() async throws {
        let mockRepository = MockTaskRepository()
        let useCase = StageProgressionUseCase(taskRepository: mockRepository)
        
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        let currentStage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: 3,
            startDate: yesterday,
            endDate: yesterday,
            durationDays: 3,
            successDays: 3,
            resultRaw: "success"
        )
        
        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: yesterday,
            endDate: yesterday,
            stages: [currentStage],
            records: []
        )
        
        mockRepository.tasks[task.id] = task
        
        try await useCase.createNextStage(for: task.id)
        
        let updatedTask = mockRepository.tasks[task.id]
        #expect(updatedTask?.stages.count == 2)
        #expect(updatedTask?.stages.last?.stageType == .seven)
        #expect(updatedTask?.stages.last?.durationDays == 7)
    }
    
    @Test
    func testCreateNextStageForFinalStage() async throws {
        let mockRepository = MockTaskRepository()
        let useCase = StageProgressionUseCase(taskRepository: mockRepository)
        
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        let currentStage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: 30,
            startDate: yesterday,
            endDate: yesterday,
            durationDays: 30,
            successDays: 20,
            resultRaw: "success"
        )
        
        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: yesterday,
            endDate: yesterday,
            stages: [currentStage],
            records: []
        )
        
        mockRepository.tasks[task.id] = task
        
        try await useCase.createNextStage(for: task.id)
        
        let updatedTask = mockRepository.tasks[task.id]
        #expect(updatedTask?.stages.count == 1)
    }
    
    @Test
    func testResetStageRecords() async throws {
        let mockRepository = MockTaskRepository()
        let useCase = StageProgressionUseCase(taskRepository: mockRepository)
        
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: today)!
        
        let currentStage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: 7,
            startDate: lastWeek,
            endDate: yesterday,
            durationDays: 7,
            successDays: 3,
            resultRaw: "fail"
        )
        
        let records = [
            DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: lastWeek, imagePath: nil),
            DailyRecordSnapshot(id: UUID(), memo: "", check: false, date: today, imagePath: nil)
        ]
        
        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: lastWeek,
            endDate: yesterday,
            stages: [currentStage],
            records: records
        )
        
        mockRepository.tasks[task.id] = task
        
        try await useCase.resetStageRecords(for: task.id)
        
        let updatedTask = mockRepository.tasks[task.id]
        #expect(updatedTask?.stages.count == 1)
        #expect(updatedTask?.stages.last?.startDate == today)
        #expect(updatedTask?.records.count == 1)
    }
}

private actor MockTaskRepository: TaskRepositoryPort {
    var tasks: [TaskID: Task] = [:]
    
    init() {
        super.init(
            fetchActiveTasks: { [] },
            fetchTask: { [weak self] id in
                self?.tasks[id]
            },
            addTask: { _ in },
            updateTask: { [weak self] task in
                self?.tasks[task.id] = task
            },
            deleteTask: { _ in },
            fetchTasksByStatus: { _ in [] }
        )
    }
}
