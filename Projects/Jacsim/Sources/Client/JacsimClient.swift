import ComposableArchitecture
import ExternalInterface
import Domain
import Data
import Foundation

public struct JacsimClientPort: Sendable {
    public var fetchActiveTasks: @Sendable () async throws -> [Domain.Task]
    public var fetchTask: @Sendable (TaskID) async throws -> Domain.Task?
    public var addTask: @Sendable (Domain.Task) async throws -> Void
    public var updateTask: @Sendable (Domain.Task) async throws -> Void
    public var deleteTask: @Sendable (TaskID) async throws -> Void
    public var fetchTasksByStatus: @Sendable (ChallengeStatus) async throws -> [Domain.Task]
    
    public var fetchIsSuccess: @Sendable () async throws -> [Domain.Task]
    public var fetchIsFail: @Sendable () async throws -> [Domain.Task]
    public var deleteAlarm: @Sendable (TaskID) async -> Void
    public var updateTaskInfo: @Sendable (Domain.Task, String, Int, Bool, Date) async -> Void
    public var evaluateStageResult: @Sendable (StageSnapshot) async -> StageResult
    public var createNextStage: @Sendable (TaskID) async -> Void
    public var updateMemo: @Sendable (TaskID, Int, String) async -> Void
    public var resetStageRecords: @Sendable (TaskID) async -> Void
    
    public init(
        fetchActiveTasks: @escaping @Sendable () async throws -> [Domain.Task],
        fetchTask: @escaping @Sendable (TaskID) async throws -> Domain.Task?,
        addTask: @escaping @Sendable (Domain.Task) async throws -> Void,
        updateTask: @escaping @Sendable (Domain.Task) async throws -> Void,
        deleteTask: @escaping @Sendable (TaskID) async throws -> Void,
        fetchTasksByStatus: @escaping @Sendable (ChallengeStatus) async throws -> [Domain.Task],
        fetchIsSuccess: @escaping @Sendable () async throws -> [Domain.Task],
        fetchIsFail: @escaping @Sendable () async throws -> [Domain.Task],
        deleteAlarm: @escaping @Sendable (TaskID) async -> Void,
        updateTaskInfo: @escaping @Sendable (Domain.Task, String, Int, Bool, Date) async -> Void,
        evaluateStageResult: @escaping @Sendable (StageSnapshot) async -> StageResult,
        createNextStage: @escaping @Sendable (TaskID) async -> Void,
        updateMemo: @escaping @Sendable (TaskID, Int, String) async -> Void,
        resetStageRecords: @escaping @Sendable (TaskID) async -> Void
    ) {
        self.fetchActiveTasks = fetchActiveTasks
        self.fetchTask = fetchTask
        self.addTask = addTask
        self.updateTask = updateTask
        self.deleteTask = deleteTask
        self.fetchTasksByStatus = fetchTasksByStatus
        self.fetchIsSuccess = fetchIsSuccess
        self.fetchIsFail = fetchIsFail
        self.deleteAlarm = deleteAlarm
        self.updateTaskInfo = updateTaskInfo
        self.evaluateStageResult = evaluateStageResult
        self.createNextStage = createNextStage
        self.updateMemo = updateMemo
        self.resetStageRecords = resetStageRecords
    }
}

private enum JacsimClientKey: DependencyKey {
    static let liveValue: JacsimClientPort = {
        let adapter = SwiftDataTaskRepositoryAdapter()
        return JacsimClientPort(
            fetchActiveTasks: { await adapter.fetchActiveTasks() },
            fetchTask: { await adapter.fetchTask(id: $0) },
            addTask: { try await adapter.addTask($0) },
            updateTask: { try await adapter.updateTask($0) },
            deleteTask: { try await adapter.deleteTask(id: $0) },
            fetchTasksByStatus: { await adapter.fetchTasksByStatus($0) },
            fetchIsSuccess: {
                let allDone = await adapter.fetchTasksByStatus(.done)
                return allDone.filter { $0.currentStage?.result == .success }
            },
            fetchIsFail: {
                let allDone = await adapter.fetchTasksByStatus(.done)
                return allDone.filter { $0.currentStage?.result == .fail }
            },
            deleteAlarm: { taskId in
            },
            updateTaskInfo: { task, title, successTarget, isAlarmEnabled, alarmDate in
                var updatedTask = task
                updatedTask.title = title
                if var lastStage = updatedTask.stages.last {
                    lastStage.durationDays = successTarget
                    let index = updatedTask.stages.count - 1
                    updatedTask.stages[index] = lastStage
                }
                try? await adapter.updateTask(updatedTask)
            },
            evaluateStageResult: { stage in
                evaluateStageResult(
                    endDate: stage.endDate,
                    durationDays: stage.durationDays,
                    successDays: stage.successDays
                )
            },
            createNextStage: { taskId in
                guard var task = try? await adapter.fetchTask(id: taskId) else { return }
                guard let lastStage = task.stages.last else { return }
                guard let nextStageType = lastStage.stageType.next else { return }

                let calendar = Calendar.current
                guard let nextStartDate = calendar.date(byAdding: .day, value: 1, to: lastStage.endDate) else { return }

                let duration = nextStageType.rawValue
                guard let nextEndDate = calendar.date(byAdding: .day, value: duration - 1, to: nextStartDate) else { return }

                let newStage = Domain.StageSnapshot(
                    id: UUID(),
                    stageTypeRaw: nextStageType.rawValue,
                    startDate: nextStartDate,
                    endDate: nextEndDate,
                    durationDays: duration,
                    successDays: 0,
                    resultRaw: Domain.StageResult.inProgress.rawValue
                )

                task.stages.append(newStage)
                try? await adapter.updateTask(task)
            },
            updateMemo: { taskId, index, memo in
                guard var task = try? await adapter.fetchTask(id: taskId) else { return }
                guard task.records.indices.contains(index) else { return }
                var updatedTask = task
                updatedTask.records[index].memo = memo
                try? await adapter.updateTask(updatedTask)
            },
            resetStageRecords: { taskId in
                guard var task = try? await adapter.fetchTask(id: taskId) else { return }
                guard let lastStage = task.stages.last else { return }
                
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                
                let newStage = Domain.StageSnapshot(
                    id: UUID(),
                    stageTypeRaw: lastStage.stageTypeRaw,
                    startDate: today,
                    endDate: calendar.date(byAdding: .day, value: lastStage.durationDays - 1, to: today) ?? today,
                    durationDays: lastStage.durationDays,
                    successDays: 0,
                    resultRaw: Domain.StageResult.inProgress.rawValue
                )
                
                task.stages.removeLast()
                task.stages.append(newStage)
                
                task.records.removeAll { record in
                    let recordDate = calendar.startOfDay(for: record.date)
                    return recordDate >= today
                }
                
                try? await adapter.updateTask(task)
            }
        )
    }()
    
    static let testValue = JacsimClientPort(
        fetchActiveTasks: { [] },
        fetchTask: { _ in nil },
        addTask: { _ in },
        updateTask: { _ in },
        deleteTask: { _ in },
        fetchTasksByStatus: { _ in [] },
        fetchIsSuccess: { [] },
        fetchIsFail: { [] },
        deleteAlarm: { _ in },
        updateTaskInfo: { _, _, _, _, _ in },
        evaluateStageResult: { _ in .inProgress },
        createNextStage: { _ in },
        updateMemo: { _, _, _ in },
        resetStageRecords: { _ in }
    )
}

extension DependencyValues {
    public var jacsimClient: JacsimClientPort {
        get { self[JacsimClientKey.self] }
        set { self[JacsimClientKey.self] = newValue }
    }
}
