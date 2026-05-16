import ExternalInterface
import Domain
import Data
import Foundation
import Core

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
    public var certifyToday: @Sendable (TaskID, Int, String, String?) async -> Void
    
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
        resetStageRecords: @escaping @Sendable (TaskID) async -> Void,
        certifyToday: @escaping @Sendable (TaskID, Int, String, String?) async -> Void
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
        self.certifyToday = certifyToday
    }
}
public struct TaskQueryClientPort: Sendable {
    public var fetchActiveTasks: @Sendable () async throws -> [Domain.Task]
    public var fetchTask: @Sendable (TaskID) async throws -> Domain.Task?
    public var fetchTasksByStatus: @Sendable (ChallengeStatus) async throws -> [Domain.Task]
    public var fetchIsSuccess: @Sendable () async throws -> [Domain.Task]
    public var fetchIsFail: @Sendable () async throws -> [Domain.Task]

    public init(
        fetchActiveTasks: @escaping @Sendable () async throws -> [Domain.Task],
        fetchTask: @escaping @Sendable (TaskID) async throws -> Domain.Task?,
        fetchTasksByStatus: @escaping @Sendable (ChallengeStatus) async throws -> [Domain.Task],
        fetchIsSuccess: @escaping @Sendable () async throws -> [Domain.Task],
        fetchIsFail: @escaping @Sendable () async throws -> [Domain.Task]
    ) {
        self.fetchActiveTasks = fetchActiveTasks
        self.fetchTask = fetchTask
        self.fetchTasksByStatus = fetchTasksByStatus
        self.fetchIsSuccess = fetchIsSuccess
        self.fetchIsFail = fetchIsFail
    }
}

public struct TaskCommandClientPort: Sendable {
    public var addTask: @Sendable (Domain.Task) async throws -> Void
    public var updateTask: @Sendable (Domain.Task) async throws -> Void
    public var deleteTask: @Sendable (TaskID) async throws -> Void
    public var updateTaskInfo: @Sendable (Domain.Task, String, Int, Bool, Date) async -> Void
    public var updateVisibility: @Sendable (TaskID, TaskVisibility) async throws -> Void

    public init(
        addTask: @escaping @Sendable (Domain.Task) async throws -> Void,
        updateTask: @escaping @Sendable (Domain.Task) async throws -> Void,
        deleteTask: @escaping @Sendable (TaskID) async throws -> Void,
        updateTaskInfo: @escaping @Sendable (Domain.Task, String, Int, Bool, Date) async -> Void,
        updateVisibility: @escaping @Sendable (TaskID, TaskVisibility) async throws -> Void = { _, _ in }
    ) {
        self.addTask = addTask
        self.updateTask = updateTask
        self.deleteTask = deleteTask
        self.updateTaskInfo = updateTaskInfo
        self.updateVisibility = updateVisibility
    }
}

public struct StageFlowClientPort: Sendable {
    public var evaluateStageResult: @Sendable (StageSnapshot) async -> StageResult
    public var createNextStage: @Sendable (TaskID) async -> Void
    public var resetStageRecords: @Sendable (TaskID) async -> Void

    public init(
        evaluateStageResult: @escaping @Sendable (StageSnapshot) async -> StageResult,
        createNextStage: @escaping @Sendable (TaskID) async -> Void,
        resetStageRecords: @escaping @Sendable (TaskID) async -> Void
    ) {
        self.evaluateStageResult = evaluateStageResult
        self.createNextStage = createNextStage
        self.resetStageRecords = resetStageRecords
    }
}

public struct CertificationClientPort: Sendable {
    public var updateMemo: @Sendable (TaskID, Int, String) async -> Void
    public var certifyToday: @Sendable (TaskID, Int, String, String?) async -> Void

    public init(
        updateMemo: @escaping @Sendable (TaskID, Int, String) async -> Void,
        certifyToday: @escaping @Sendable (TaskID, Int, String, String?) async -> Void
    ) {
        self.updateMemo = updateMemo
        self.certifyToday = certifyToday
    }
}
