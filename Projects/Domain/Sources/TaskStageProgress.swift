import Foundation

public extension Task {
    func records(
        in stage: StageSnapshot,
        calendar: Calendar = .current
    ) -> [DailyRecordSnapshot] {
        let stageStart = calendar.startOfDay(for: stage.startDate)
        let stageEnd = calendar.startOfDay(for: stage.endDate)

        return records
            .filter { record in
                let recordDate = calendar.startOfDay(for: record.date)
                return recordDate >= stageStart && recordDate <= stageEnd
            }
            .sorted { $0.date < $1.date }
    }

    func successCount(
        in stage: StageSnapshot,
        calendar: Calendar = .current
    ) -> Int {
        records(in: stage, calendar: calendar).filter(\.check).count
    }

    func refreshingStageProgress(
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Task {
        var task = self

        for index in task.stages.indices {
            var stage = task.stages[index]
            let successDays = task.successCount(in: stage, calendar: calendar)
            stage.successDays = successDays
            stage.result = evaluateStageResult(
                endDate: stage.endDate,
                durationDays: stage.durationDays,
                successDays: successDays,
                now: now
            )
            task.stages[index] = stage
        }

        return task
    }

    var isTerminallyDone: Bool {
        guard let stage = stages.last else { return false }

        switch stage.result {
        case .inProgress:
            return false
        case .success:
            return stage.stageType.next == nil
        case .fail:
            return true
        }
    }

    var isTerminallySuccessful: Bool {
        guard let stage = stages.last else { return false }
        return stage.result == .success && stage.stageType.next == nil
    }
}
