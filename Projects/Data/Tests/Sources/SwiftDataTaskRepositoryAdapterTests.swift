import Foundation
import SwiftData
import Testing
@testable import Adapters
import Domain

struct SwiftDataTaskRepositoryAdapterTests {
    @Test
    func repositorySeparatesActiveAndDoneTasksFromPersistedStageState() async throws {
        let adapter = try SwiftDataTaskRepositoryAdapter(container: makeInMemoryContainer())

        try await adapter.addTask(makeTask(title: "진행중", stageResult: .inProgress, startOffset: 0))
        try await adapter.addTask(makeTask(title: "성공", stageResult: .success, startOffset: 10))
        try await adapter.addTask(makeTask(title: "실패", stageResult: .fail, startOffset: 20))

        let activeTasks = try await adapter.fetchActiveTasks()
        let doneTasks = try await adapter.fetchTasksByStatus(.done)

        #expect(activeTasks.map(\.title) == ["진행중"])
        #expect(Set(doneTasks.map(\.title)) == Set(["성공", "실패"]))
    }

    @Test
    func repositoryThrowsTaskNotFoundForMissingUpdateAndDeleteTargets() async throws {
        let adapter = try SwiftDataTaskRepositoryAdapter(container: makeInMemoryContainer())
        let missingTask = makeTask(title: "없음", stageResult: .inProgress, startOffset: 0)

        do {
            try await adapter.updateTask(missingTask)
            Issue.record("Expected taskNotFound on update")
        } catch let error as TaskRepositoryAdapterError {
            switch error {
            case let .taskNotFound(taskID):
                #expect(taskID == missingTask.id)
            default:
                Issue.record("Unexpected update error: \(error)")
            }
        }

        do {
            try await adapter.deleteTask(id: missingTask.id)
            Issue.record("Expected taskNotFound on delete")
        } catch let error as TaskRepositoryAdapterError {
            switch error {
            case let .taskNotFound(taskID):
                #expect(taskID == missingTask.id)
            default:
                Issue.record("Unexpected delete error: \(error)")
            }
        }
    }

    private func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([
            UserJacsimModel.self,
            AppSettingsModel.self,
            CertifiedModel.self,
            StageModel.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    private func makeTask(title: String, stageResult: StageResult, startOffset: Int) -> Task {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: calendar.date(byAdding: .day, value: startOffset, to: Date(timeIntervalSince1970: 1_700_000_000))!)
        let end = calendar.date(byAdding: .day, value: 2, to: start) ?? start
        let successDays = stageResult == .success ? 2 : 1

        return Task(
            id: TaskID(UUID()),
            title: title,
            startDate: start,
            endDate: end,
            stages: [
                StageSnapshot(
                    id: UUID(),
                    stageTypeRaw: StageType.three.rawValue,
                    startDate: start,
                    endDate: end,
                    durationDays: 3,
                    successDays: successDays,
                    resultRaw: stageResult.rawValue
                )
            ],
            records: []
        )
    }
}
