import Foundation

public struct TaskLifecycleService: Sendable {
    public init() {}

    public func normalize(_ task: Task, now: Date = .now) -> Task {
        var normalizedTask = task
        let calendar = Calendar.current

        normalizedTask.stages = task.stages.map { stage in
            var normalizedStage = stage
            let successDays = task.records.filter { record in
                guard record.check else { return false }
                let recordDate = calendar.startOfDay(for: record.date)
                return recordDate >= calendar.startOfDay(for: stage.startDate)
                    && recordDate <= calendar.startOfDay(for: stage.endDate)
            }.count

            normalizedStage.successDays = successDays
            normalizedStage.result = evaluateStageResult(
                endDate: stage.endDate,
                durationDays: stage.durationDays,
                successDays: successDays,
                now: now
            )
            return normalizedStage
        }

        return normalizedTask
    }
}
