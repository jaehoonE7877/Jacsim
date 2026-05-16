import Foundation

public struct GraduationContext: Sendable, Codable, Equatable, Identifiable {
    public let id: UUID
    public let taskId: TaskID
    public let taskTitle: String
    public let stageTypeRaw: Int
    public let durationDays: Int
    public let successDays: Int

    public init(
        id: UUID = UUID(),
        taskId: TaskID,
        taskTitle: String,
        stageTypeRaw: Int,
        durationDays: Int,
        successDays: Int
    ) {
        self.id = id
        self.taskId = taskId
        self.taskTitle = taskTitle
        self.stageTypeRaw = stageTypeRaw
        self.durationDays = durationDays
        self.successDays = successDays
    }

    public var stageType: StageType {
        StageType(rawValue: stageTypeRaw) ?? .three
    }
}

public struct StageGraduationDetector: Sendable {
    public init() {}

    public func graduationContext(before: Task, after: Task) -> GraduationContext? {
        let beforeStages = Dictionary(uniqueKeysWithValues: before.stages.map { ($0.id, $0.result) })
        guard let graduatedStage = after.stages.last(where: { stage in
            beforeStages[stage.id] == .inProgress
                && (stage.result == .success || didCertifyLastStageDay(before: before, after: after, stage: stage))
        }) else {
            return nil
        }

        return GraduationContext(
            taskId: after.id,
            taskTitle: after.title,
            stageTypeRaw: graduatedStage.stageTypeRaw,
            durationDays: graduatedStage.durationDays,
            successDays: graduatedStage.successDays
        )
    }

    private func didCertifyLastStageDay(before: Task, after: Task, stage: StageSnapshot) -> Bool {
        guard stage.successDays >= minimumSuccessDays(durationDays: stage.durationDays) else { return false }

        let calendar = Calendar.current
        let lastDay = calendar.startOfDay(for: stage.endDate)
        let beforeChecked = before.records.contains {
            calendar.isDate($0.date, inSameDayAs: lastDay) && $0.check
        }
        let afterChecked = after.records.contains {
            calendar.isDate($0.date, inSameDayAs: lastDay) && $0.check
        }
        return !beforeChecked && afterChecked
    }
}
