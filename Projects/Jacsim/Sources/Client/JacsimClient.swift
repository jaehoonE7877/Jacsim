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

    public init(
        addTask: @escaping @Sendable (Domain.Task) async throws -> Void,
        updateTask: @escaping @Sendable (Domain.Task) async throws -> Void,
        deleteTask: @escaping @Sendable (TaskID) async throws -> Void,
        updateTaskInfo: @escaping @Sendable (Domain.Task, String, Int, Bool, Date) async -> Void
    ) {
        self.addTask = addTask
        self.updateTask = updateTask
        self.deleteTask = deleteTask
        self.updateTaskInfo = updateTaskInfo
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
            fetchTask: { await adapter.fetchTask(id: $0) },
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
            updateTaskInfo: { task, title, successTarget, isAlarmEnabled, alarmDate in
                var task = task
                task.isNotificationEnabled = isAlarmEnabled
                task.alarm = isAlarmEnabled ? alarmDate : nil
                do {
                    _ = try await taskUpdateUseCase.updateTaskInfo(
                        task: task,
                        title: title,
                        durationDays: successTarget,
                        isNotificationEnabled: isAlarmEnabled,
                        alarmDate: alarmDate
                    )
                } catch {
                    Logger.certificationFailed(error: error)
                }
            },
            evaluateStageResult: { stage in
                stageEvaluationService.evaluateStage(
                    endDate: stage.endDate,
                    durationDays: stage.durationDays,
                    successDays: stage.successDays
                )
            },
            createNextStage: { taskId in
                do {
                    try await stageProgressionUseCase.createNextStage(for: taskId)
                } catch {
                    Logger.certificationFailed(error: error)
                }
            },
            updateMemo: { taskId, index, memo in
                do {
                    try await certificationUseCase.updateMemo(
                        taskId: taskId,
                        index: index,
                        memo: memo
                    )
                } catch {
                    Logger.certificationFailed(error: error)
                }
            },
            resetStageRecords: { taskId in
                do {
                    try await stageProgressionUseCase.resetStageRecords(for: taskId)
                } catch {
                    Logger.certificationFailed(error: error)
                }
            },
            certifyToday: { taskId, index, memo, imagePath in
                let startTime = Date()
                Logger.certificationSaving(
                    taskId: taskId.rawValue.uuidString,
                    index: index,
                    memo: memo,
                    imagePath: imagePath
                )
                do {
                    try await certificationUseCase.certifyToday(
                        taskId: taskId,
                        index: index,
                        memo: memo,
                        imagePath: imagePath
                    )
                    Logger.certificationSavedToSwiftData(
                        duration: Date().timeIntervalSince(startTime)
                    )
                } catch {
                    Logger.certificationFailed(error: error)
                }
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

private enum TaskQueryClientKey: DependencyKey {
    static let liveValue = TaskQueryClientPort(
        fetchActiveTasks: { try await JacsimClientKey.liveValue.fetchActiveTasks() },
        fetchTask: { try await JacsimClientKey.liveValue.fetchTask($0) },
        fetchTasksByStatus: { try await JacsimClientKey.liveValue.fetchTasksByStatus($0) },
        fetchIsSuccess: { try await JacsimClientKey.liveValue.fetchIsSuccess() },
        fetchIsFail: { try await JacsimClientKey.liveValue.fetchIsFail() }
    )

    static let testValue = TaskQueryClientPort(
        fetchActiveTasks: { [] },
        fetchTask: { _ in nil },
        fetchTasksByStatus: { _ in [] },
        fetchIsSuccess: { [] },
        fetchIsFail: { [] }
    )
}

private enum TaskCommandClientKey: DependencyKey {
    static let liveValue = TaskCommandClientPort(
        addTask: { try await JacsimClientKey.liveValue.addTask($0) },
        updateTask: { try await JacsimClientKey.liveValue.updateTask($0) },
        deleteTask: { try await JacsimClientKey.liveValue.deleteTask($0) },
        updateTaskInfo: { await JacsimClientKey.liveValue.updateTaskInfo($0, $1, $2, $3, $4) }
    )

    static let testValue = TaskCommandClientPort(
        addTask: { _ in },
        updateTask: { _ in },
        deleteTask: { _ in },
        updateTaskInfo: { _, _, _, _, _ in }
    )
}

private enum StageFlowClientKey: DependencyKey {
    static let liveValue = StageFlowClientPort(
        evaluateStageResult: { await JacsimClientKey.liveValue.evaluateStageResult($0) },
        createNextStage: { await JacsimClientKey.liveValue.createNextStage($0) },
        resetStageRecords: { await JacsimClientKey.liveValue.resetStageRecords($0) }
    )

    static let testValue = StageFlowClientPort(
        evaluateStageResult: { _ in .inProgress },
        createNextStage: { _ in },
        resetStageRecords: { _ in }
    )
}

private enum CertificationClientKey: DependencyKey {
    static let liveValue = CertificationClientPort(
        updateMemo: { await JacsimClientKey.liveValue.updateMemo($0, $1, $2) },
        certifyToday: { await JacsimClientKey.liveValue.certifyToday($0, $1, $2, $3) }
    )

    static let testValue = CertificationClientPort(
        updateMemo: { _, _, _ in },
        certifyToday: { _, _, _, _ in }
    )
}

extension DependencyValues {
    public var jacsimClient: JacsimClientPort {
        get { self[JacsimClientKey.self] }
        set { self[JacsimClientKey.self] = newValue }
    }

    var taskQueryClient: TaskQueryClientPort {
        get { self[TaskQueryClientKey.self] }
        set { self[TaskQueryClientKey.self] = newValue }
    }

    var taskCommandClient: TaskCommandClientPort {
        get { self[TaskCommandClientKey.self] }
        set { self[TaskCommandClientKey.self] = newValue }
    }

    var stageFlowClient: StageFlowClientPort {
        get { self[StageFlowClientKey.self] }
        set { self[StageFlowClientKey.self] = newValue }
    }

    var certificationClient: CertificationClientPort {
        get { self[CertificationClientKey.self] }
        set { self[CertificationClientKey.self] = newValue }
    }
}
