import Foundation
import Testing
@testable import Domain

struct CertificationUseCaseTests {
    
    @Test
    func testCertifyToday() async throws {
        let mockRepository = MockTaskRepository()
        let useCase = CertificationUseCase(taskRepository: mockRepository)
        
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        let records = [
            DailyRecordSnapshot(id: UUID(), memo: "", check: false, date: yesterday, imagePath: nil),
            DailyRecordSnapshot(id: UUID(), memo: "", check: false, date: today, imagePath: nil)
        ]
        
        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: yesterday,
            endDate: today,
            stages: [],
            records: records
        )
        
        mockRepository.tasks[task.id] = task
        
        try await useCase.certifyToday(
            taskId: task.id,
            index: 1,
            memo: "Completed!",
            imagePath: "image.jpg"
        )
        
        let updatedTask = mockRepository.tasks[task.id]
        #expect(updatedTask?.records[1].check == true)
        #expect(updatedTask?.records[1].memo == "Completed!")
        #expect(updatedTask?.records[1].imagePath == "image.jpg")
    }
    
    @Test
    func testCertifyTodayThrowsForInvalidIndex() async {
        let mockRepository = MockTaskRepository()
        let useCase = CertificationUseCase(taskRepository: mockRepository)
        
        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: Date(),
            endDate: Date(),
            stages: [],
            records: []
        )
        
        mockRepository.tasks[task.id] = task
        
        await #expect(throws: CertificationError.invalidRecordIndex) {
            try await useCase.certifyToday(
                taskId: task.id,
                index: 0,
                memo: "",
                imagePath: nil
            )
        }
    }
    
    @Test
    func testUpdateMemo() async throws {
        let mockRepository = MockTaskRepository()
        let useCase = CertificationUseCase(taskRepository: mockRepository)
        
        let today = Date()
        
        let records = [
            DailyRecordSnapshot(id: UUID(), memo: "Old memo", check: true, date: today, imagePath: nil)
        ]
        
        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: today,
            endDate: today,
            stages: [],
            records: records
        )
        
        mockRepository.tasks[task.id] = task
        
        try await useCase.updateMemo(
            taskId: task.id,
            index: 0,
            memo: "New memo"
        )
        
        let updatedTask = mockRepository.tasks[task.id]
        #expect(updatedTask?.records[0].memo == "New memo")
        #expect(updatedTask?.records[0].check == true)
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
