import Foundation
import Testing
@testable import Domain

struct CertificationUseCaseTests {
    @Test
    func testCertifyToday() async throws {
        let store = MockTaskStore()
        let useCase = CertificationUseCase(
            fetchTask: { try await store.fetchTask(id: $0) },
            updateTask: { try await store.updateTask($0) }
        )

        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: yesterday,
            endDate: today,
            stages: [],
            records: [
                DailyRecordSnapshot(id: UUID(), memo: "", check: false, date: yesterday, imagePath: nil),
                DailyRecordSnapshot(id: UUID(), memo: "", check: false, date: today, imagePath: nil)
            ]
        )

        await store.setTask(task)

        try await useCase.certifyToday(
            taskId: task.id,
            index: 1,
            memo: "Completed!",
            imagePath: "image.jpg"
        )

        let updatedTask = try await store.fetchTask(id: task.id)
        #expect(updatedTask?.records[1].check == true)
        #expect(updatedTask?.records[1].memo == "Completed!")
        #expect(updatedTask?.records[1].imagePath == "image.jpg")
    }

    @Test
    func testCertifyTodayThrowsForInvalidIndex() async {
        let store = MockTaskStore()
        let useCase = CertificationUseCase(
            fetchTask: { try await store.fetchTask(id: $0) },
            updateTask: { try await store.updateTask($0) }
        )

        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: Date(),
            endDate: Date(),
            stages: [],
            records: []
        )

        await store.setTask(task)

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
        let store = MockTaskStore()
        let useCase = CertificationUseCase(
            fetchTask: { try await store.fetchTask(id: $0) },
            updateTask: { try await store.updateTask($0) }
        )

        let today = Date()

        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: today,
            endDate: today,
            stages: [],
            records: [
                DailyRecordSnapshot(id: UUID(), memo: "Old memo", check: true, date: today, imagePath: nil)
            ]
        )

        await store.setTask(task)

        try await useCase.updateMemo(
            taskId: task.id,
            index: 0,
            memo: "New memo"
        )

        let updatedTask = try await store.fetchTask(id: task.id)
        #expect(updatedTask?.records[0].memo == "New memo")
        #expect(updatedTask?.records[0].check == true)
    }
}

private actor MockTaskStore {
    private var tasks: [TaskID: Task] = [:]

    func setTask(_ task: Task) {
        tasks[task.id] = task
    }

    func fetchTask(id: TaskID) throws -> Task? {
        tasks[id]
    }

    func updateTask(_ task: Task) throws {
        tasks[task.id] = task
    }
}
