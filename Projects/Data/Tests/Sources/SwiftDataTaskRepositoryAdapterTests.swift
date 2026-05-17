import Foundation
import SwiftData
import Testing
@testable import Data
import Domain

struct SwiftDataTaskRepositoryAdapterTests {
    @Test
    func repositorySeparatesActiveAndDoneTasksFromPersistedStageState() async throws {
        let adapter = try SwiftDataTaskRepositoryAdapter(container: makeInMemoryContainer())
        let port = adapter.makePort()

        let today = Date()
        try await port.addTask(makeTask(title: "진행중", stageResult: .inProgress, startOffset: -1, baseDate: today))
        try await port.addTask(makeTask(title: "성공", stageResult: .success, startOffset: -31, stageType: .thirty, baseDate: today))
        try await port.addTask(makeTask(title: "완주", stageResult: .success, startOffset: -181, stageType: .oneEighty, baseDate: today))
        try await port.addTask(makeTask(title: "실패", stageResult: .fail, startOffset: -10, baseDate: today))

        let activeTasks = try await port.fetchActiveTasks()
        let doneTasks = try await port.fetchTasksByStatus(.done)

        #expect(Set(activeTasks.map(\.title)) == Set(["진행중", "성공", "실패"]))
        #expect(Set(doneTasks.map(\.title)) == Set(["완주", "실패"]))
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
                    check: true,
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
        } catch TaskRepositoryAdapterError.taskNotFound(let taskID) {
            #expect(taskID == missingTask.id)
        } catch {
            Issue.record("Unexpected update error: \(error)")
        }

        do {
            try await port.deleteTask(missingTask.id)
            Issue.record("Expected taskNotFound on delete")
        } catch TaskRepositoryAdapterError.taskNotFound(let taskID) {
            #expect(taskID == missingTask.id)
        } catch {
            Issue.record("Unexpected delete error: \(error)")
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
        stageType: StageType = .three,
        baseDate: Date = Date(timeIntervalSince1970: 1_700_000_000),
        records: [DailyRecordSnapshot] = []
    ) -> Task {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: calendar.date(byAdding: .day, value: startOffset, to: baseDate)!)
        let end = calendar.date(byAdding: .day, value: stageType.durationDays - 1, to: start) ?? start
        let seededRecords = records.isEmpty
            ? makeRecords(stageResult: stageResult, start: start, durationDays: stageType.durationDays)
            : records
        let successDays = seededRecords.filter(\.check).count

        return Task(
            id: TaskID(UUID()),
            title: title,
            startDate: start,
            endDate: end,
            stages: [
                StageSnapshot(
                    id: UUID(),
                    stageTypeRaw: stageType.rawValue,
                    startDate: start,
                    endDate: end,
                    durationDays: stageType.durationDays,
                    successDays: successDays,
                    resultRaw: stageResult.rawValue
                )
            ],
            records: seededRecords
        )
    }

    private func makeRecords(
        stageResult: StageResult,
        start: Date,
        durationDays: Int
    ) -> [DailyRecordSnapshot] {
        let checkedCount: Int
        switch stageResult {
        case .success:
            checkedCount = minimumSuccessDays(durationDays: durationDays)
        case .fail:
            checkedCount = max(0, minimumSuccessDays(durationDays: durationDays) - 1)
        case .inProgress:
            checkedCount = 0
        }

        return (0..<durationDays).map { offset in
            DailyRecordSnapshot(
                id: UUID(),
                memo: "",
                check: offset < checkedCount,
                date: Calendar.current.date(byAdding: .day, value: offset, to: start) ?? start,
                imagePath: nil
            )
        }
    }
}
