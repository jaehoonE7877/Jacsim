import Foundation

public protocol StageProgressionUseCaseProtocol: Sendable {
    func createNextStage(for taskId: TaskID) async throws
    func resetStageRecords(for taskId: TaskID) async throws
}

public struct StageProgressionUseCase: StageProgressionUseCaseProtocol {
    public typealias FetchTaskHandler = @Sendable (TaskID) async -> Task?
    public typealias UpdateTaskHandler = @Sendable (Task) async throws -> Void
    
    private let fetchTask: FetchTaskHandler
    private let updateTask: UpdateTaskHandler
    
    public init(
        fetchTask: @escaping FetchTaskHandler,
        updateTask: @escaping UpdateTaskHandler
    ) {
        self.fetchTask = fetchTask
        self.updateTask = updateTask
    }
    
    public func createNextStage(for taskId: TaskID) async throws {
        guard var task = await fetchTask(taskId) else { return }
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
        try await updateTask(task)
    }
    
    public func resetStageRecords(for taskId: TaskID) async throws {
        guard var task = await fetchTask(taskId) else { return }
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
        
        task.records.removeAll { record in
            let recordDate = calendar.startOfDay(for: record.date)
            return recordDate >= today
        }
        
        try await updateTask(task)
    }
}
