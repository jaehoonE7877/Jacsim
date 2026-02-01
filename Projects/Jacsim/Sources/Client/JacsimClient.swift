import ComposableArchitecture
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

private enum JacsimClientKey: DependencyKey {
    static let liveValue: JacsimClientPort = {
        let adapter = SwiftDataTaskRepositoryAdapter()
        let taskRepository = TaskRepositoryPort(
            fetchActiveTasks: { await adapter.fetchActiveTasks() },
            fetchTask: { await adapter.fetchTask(id: $0) },
            addTask: { try await adapter.addTask($0) },
            updateTask: { try await adapter.updateTask($0) },
            deleteTask: { try await adapter.deleteTask(id: $0) },
            fetchTasksByStatus: { await adapter.fetchTasksByStatus($0) }
        )
        
        let taskStatusService = TaskStatusService()
        let stageEvaluationService = StageEvaluationService()
        let taskUpdateUseCase = TaskUpdateUseCase(updateTask: { try await adapter.updateTask($0) })
        let stageProgressionUseCase = StageProgressionUseCase(
            fetchTask: { await adapter.fetchTask(id: $0) },
            updateTask: { try await adapter.updateTask($0) }
        )
        let certificationUseCase = CertificationUseCase(
            fetchTask: { try await adapter.fetchTask(id: $0) },
            updateTask: { try await adapter.updateTask($0) }
        )
        
        return JacsimClientPort(
            fetchActiveTasks: { try await taskRepository.fetchActiveTasks() },
            fetchTask: { try await taskRepository.fetchTask($0) },
            addTask: { task in
                let startTime = Date()
                try await taskRepository.addTask(task)
                Logger.taskSaved(duration: Date().timeIntervalSince(startTime))
            },
            updateTask: { try await taskRepository.updateTask($0) },
            deleteTask: { try await taskRepository.deleteTask($0) },
            fetchTasksByStatus: { try await taskRepository.fetchTasksByStatus($0) },
            fetchIsSuccess: {
                let allDone = try await taskRepository.fetchTasksByStatus(.done)
                return taskStatusService.filterSuccessTasks(allDone)
            },
            fetchIsFail: {
                let allDone = try await taskRepository.fetchTasksByStatus(.done)
                return taskStatusService.filterFailTasks(allDone)
            },
            deleteAlarm: { _ in },
            updateTaskInfo: { task, title, successTarget, _, _ in
                _ = try? await taskUpdateUseCase.updateTaskInfo(
                    task: task,
                    title: title,
                    durationDays: successTarget
                )
            },
            evaluateStageResult: { stage in
                stageEvaluationService.evaluateStage(
                    endDate: stage.endDate,
                    durationDays: stage.durationDays,
                    successDays: stage.successDays
                )
            },
            createNextStage: { taskId in
                try? await stageProgressionUseCase.createNextStage(for: taskId)
            },
            updateMemo: { taskId, index, memo in
                try? await certificationUseCase.updateMemo(
                    taskId: taskId,
                    index: index,
                    memo: memo
                )
            },
            resetStageRecords: { taskId in
                try? await stageProgressionUseCase.resetStageRecords(for: taskId)
            },
            certifyToday: { taskId, index, memo, imagePath in
                let startTime = Date()
                Logger.certificationSaving(
                    taskId: taskId.rawValue.uuidString,
                    index: index,
                    memo: memo,
                    imagePath: imagePath
                )
                try? await certificationUseCase.certifyToday(
                    taskId: taskId,
                    index: index,
                    memo: memo,
                    imagePath: imagePath
                )
                Logger.certificationSavedToSwiftData(
                    duration: Date().timeIntervalSince(startTime)
                )
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
        resetStageRecords: { _ in },
        certifyToday: { _, _, _, _ in }
    )
}

extension DependencyValues {
    public var jacsimClient: JacsimClientPort {
        get { self[JacsimClientKey.self] }
        set { self[JacsimClientKey.self] = newValue }
    }
}
