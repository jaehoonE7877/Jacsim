import Foundation
import Domain
import Ports

public struct StageProgressionUseCase: Sendable {
    private let taskRepository: TaskRepositoryPort

    public init(taskRepository: TaskRepositoryPort) {
        self.taskRepository = taskRepository
    }

    public func createNextStage(for taskId: TaskID) async throws {
        guard var task = try await taskRepository.fetchTask(taskId) else { return }
        guard let lastStage = task.stages.last else { return }
        guard let nextStageType = lastStage.stageType.next else { return }

        let calendar = Calendar.current
        guard let nextStartDate = calendar.date(byAdding: .day, value: 1, to: lastStage.endDate) else { return }

        let duration = nextStageType.rawValue
        guard let nextEndDate = calendar.date(byAdding: .day, value: duration - 1, to: nextStartDate) else { return }

        let newStage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: nextStageType.rawValue,
            startDate: nextStartDate,
            endDate: nextEndDate,
            durationDays: duration,
            successDays: 0,
            resultRaw: StageResult.inProgress.rawValue
        )

        task.stages.append(newStage)
        task.endDate = nextEndDate
        task.records.removeAll { record in
            let recordDate = calendar.startOfDay(for: record.date)
            return recordDate >= calendar.startOfDay(for: nextStartDate)
                && recordDate <= calendar.startOfDay(for: nextEndDate)
        }
        task.records.append(contentsOf: makeRecords(startDate: nextStartDate, endDate: nextEndDate, calendar: calendar))
        task.records.sort { $0.date < $1.date }
        try await taskRepository.updateTask(task)
    }

    public func resetStageRecords(for taskId: TaskID) async throws {
        guard var task = try await taskRepository.fetchTask(taskId) else { return }
        guard let lastStage = task.stages.last else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let newStage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: lastStage.stageTypeRaw,
            startDate: today,
            endDate: calendar.date(byAdding: .day, value: lastStage.durationDays - 1, to: today) ?? today,
            durationDays: lastStage.durationDays,
            successDays: 0,
            resultRaw: StageResult.inProgress.rawValue
        )

        task.stages.removeLast()
        task.stages.append(newStage)
        task.endDate = newStage.endDate

        task.records.removeAll { record in
            let recordDate = calendar.startOfDay(for: record.date)
            return recordDate >= today
        }
        task.records.append(contentsOf: makeRecords(startDate: today, endDate: newStage.endDate, calendar: calendar))
        task.records.sort { $0.date < $1.date }

        try await taskRepository.updateTask(task)
    }

    private func makeRecords(
        startDate: Date,
        endDate: Date,
        calendar: Calendar
    ) -> [DailyRecordSnapshot] {
        var records: [DailyRecordSnapshot] = []
        var currentDate = calendar.startOfDay(for: startDate)
        let stageEndDate = calendar.startOfDay(for: endDate)

        while currentDate <= stageEndDate {
            records.append(
                DailyRecordSnapshot(
                    id: UUID(),
                    memo: "",
                    check: false,
                    date: currentDate,
                    imagePath: nil
                )
            )
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)
                ?? currentDate.addingTimeInterval(86400)
        }

        return records
    }
}
