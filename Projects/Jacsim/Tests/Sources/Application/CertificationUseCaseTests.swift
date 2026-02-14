import Foundation
import Testing
import Domain
import ExternalInterface

@testable import Jacsim

struct CertificationUseCaseTests {
    @Test
    func testCertifyToday() async throws {
        let store = MockTaskStore()
        let repository = makeRepositoryPort(store: store)
        let useCase = CertificationUseCase(taskRepository: repository)

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

        let updatedTask = await store.fetchTask(id: task.id)
        #expect(updatedTask?.records[1].check == true)
        #expect(updatedTask?.records[1].memo == "Completed!")
        #expect(updatedTask?.records[1].imagePath == "image.jpg")
    }

    @Test
    func testCertifyTodayThrowsForInvalidIndex() async {
        let store = MockTaskStore()
        let repository = makeRepositoryPort(store: store)
        let useCase = CertificationUseCase(taskRepository: repository)

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
        let repository = makeRepositoryPort(store: store)
        let useCase = CertificationUseCase(taskRepository: repository)

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

        let updatedTask = await store.fetchTask(id: task.id)
        #expect(updatedTask?.records[0].memo == "New memo")
        #expect(updatedTask?.records[0].check == true)
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
