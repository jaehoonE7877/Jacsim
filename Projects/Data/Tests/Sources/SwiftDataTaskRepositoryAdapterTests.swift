import Foundation
import SwiftData
import Testing
@testable import Adapters
import Domain

struct SwiftDataTaskRepositoryAdapterTests {
    @Test
    func repositorySeparatesActiveAndDoneTasksFromPersistedStageState() async throws {
        let adapter = try SwiftDataTaskRepositoryAdapter(container: makeInMemoryContainer())
        let port = adapter.makePort()

        try await port.addTask(makeTask(title: "진행중", stageResult: .inProgress, startOffset: 0))
        try await port.addTask(makeTask(title: "성공", stageResult: .success, startOffset: 10))
        try await port.addTask(makeTask(title: "실패", stageResult: .fail, startOffset: 20))

        let activeTasks = try await port.fetchActiveTasks()
        let doneTasks = try await port.fetchTasksByStatus(.done)

        #expect(activeTasks.map(\.title) == ["진행중"])
        #expect(Set(doneTasks.map(\.title)) == Set(["성공", "실패"]))
    }

    @Test
    func repositoryRoundsTripsTaskStagesAndRecordsWithoutStageOwnedCopies() async throws {
        let adapter = try SwiftDataTaskRepositoryAdapter(container: makeInMemoryContainer())
        let port = adapter.makePort()
        let task = makeTask(
            title: "라운드트립",
            stageResult: .success,
            startOffset: 0,
            records: [
                DailyRecordSnapshot(
                    id: UUID(),
                    memo: "첫 기록",
                    check: true,
                    date: Date(timeIntervalSince1970: 1_700_000_000),
                    imagePath: "first.jpg"
                ),
                DailyRecordSnapshot(
                    id: UUID(),
                    memo: "둘째 기록",
                    check: false,
                    date: Date(timeIntervalSince1970: 1_700_086_400),
                    imagePath: nil
                )
            ]
        )

        try await port.addTask(task)

        let fetched = try await port.fetchTask(task.id)

        #expect(fetched?.stages.count == 1)
        #expect(fetched?.stages.last?.result == .success)
        #expect(fetched?.records.count == 2)
        #expect(fetched?.records.first?.memo == "첫 기록")
        #expect(fetched?.records.last?.memo == "둘째 기록")
    }

    @Test
    func repositoryThrowsTaskNotFoundForMissingUpdateAndDeleteTargets() async throws {
        let adapter = try SwiftDataTaskRepositoryAdapter(container: makeInMemoryContainer())
        let port = adapter.makePort()
        let missingTask = makeTask(title: "없음", stageResult: .inProgress, startOffset: 0)

        do {
            try await port.updateTask(missingTask)
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
            try await port.deleteTask(missingTask.id)
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
        makeTask(title: title, stageResult: stageResult, startOffset: startOffset, records: [])
    }

    private func makeTask(
        title: String,
        stageResult: StageResult,
        startOffset: Int,
        records: [DailyRecordSnapshot]
    ) -> Task {
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
            records: records
        )
    }
}
