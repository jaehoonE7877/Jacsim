import Foundation
import SwiftData
import Domain
import ExternalInterface

public enum TaskRepositoryAdapterError: Error {
    case taskNotFound(TaskID)
}

public actor SwiftDataTaskRepositoryAdapter {
    private let container: ModelContainer
    
    public init(container: ModelContainer = SwiftDataStack.shared.container) {
        self.container = container
    }

    public nonisolated func makePort() -> TaskRepositoryPort {
        let adapter = self

        return TaskRepositoryPort(
            fetchActiveTasks: { await adapter.fetchActiveTasks() },
            fetchTask: { await adapter.fetchTask(id: $0) },
            addTask: { try await adapter.addTask($0) },
            updateTask: { try await adapter.updateTask($0) },
            deleteTask: { try await adapter.deleteTask(id: $0) },
            fetchTasksByStatus: { await adapter.fetchTasksByStatus($0) }
        )
    }
    
    public func fetchActiveTasks() async -> [Domain.Task] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<UserJacsimModel>()
        let results = (try? context.fetch(descriptor)) ?? []
        let now = Date()
        let tasks = refreshTasks(from: results, in: context, now: now)
        return ActiveTaskService()
            .filterActiveTasks(tasks, referenceDate: now)
            .sorted { $0.startDate < $1.startDate }
    }
    
    public func fetchTask(id: TaskID) async -> Domain.Task? {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<UserJacsimModel>()
        guard let model = (try? context.fetch(descriptor))?
            .first(where: { $0.id == id.rawValue })
        else { return nil }

        return refreshTask(from: model, in: context, now: Date())
    }
    
    public func addTask(_ task: Domain.Task) async throws {
        let context = ModelContext(container)
        let model = mapToSwiftDataModel(task)
        context.insert(model)
        try context.save()
    }
    
    public func updateTask(_ task: Domain.Task) async throws {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<UserJacsimModel>()
        guard let existing = (try? context.fetch(descriptor))?
            .first(where: { $0.id == task.id.rawValue }) else {
            throw TaskRepositoryAdapterError.taskNotFound(task.id)
        }
        let previousRecords = existing.memoList
        let updated = mapToSwiftDataModel(task, existing: existing)
        let retainedRecordIDs = Set(updated.memoList.map(\.id))
        for record in previousRecords where !retainedRecordIDs.contains(record.id) {
            context.delete(record)
        }
        try context.save()
    }
    
    public func deleteTask(id: TaskID) async throws {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<UserJacsimModel>()
        guard let model = (try? context.fetch(descriptor))?
            .first(where: { $0.id == id.rawValue }) else {
            throw TaskRepositoryAdapterError.taskNotFound(id)
        }
        context.delete(model)
        try context.save()
    }
    
    public func fetchTasksByStatus(_ status: ChallengeStatus) async -> [Domain.Task] {
        let context = ModelContext(container)
        switch status {
        case .inProgress:
            return await fetchActiveTasks()
        case .done:
            let descriptor = FetchDescriptor<UserJacsimModel>()
            let results = (try? context.fetch(descriptor)) ?? []
            return refreshTasks(from: results, in: context, now: Date())
                .filter(\.isTerminallyDone)
                .sorted { $0.startDate < $1.startDate }
        }
    }

    private func refreshTasks(
        from models: [UserJacsimModel],
        in context: ModelContext,
        now: Date
    ) -> [Domain.Task] {
        var didUpdate = false
        let tasks = models.map { model in
            let refreshedTask = refreshTask(from: model, now: now)
            didUpdate = didUpdate || shouldPersistRefresh(refreshedTask, over: model)
            _ = mapToSwiftDataModel(refreshedTask, existing: model)
            return refreshedTask
        }

        if didUpdate {
            try? context.save()
        }

        return tasks
    }

    private func refreshTask(
        from model: UserJacsimModel,
        in context: ModelContext,
        now: Date
    ) -> Domain.Task {
        let refreshedTask = refreshTask(from: model, now: now)
        if shouldPersistRefresh(refreshedTask, over: model) {
            _ = mapToSwiftDataModel(refreshedTask, existing: model)
            try? context.save()
        }
        return refreshedTask
    }

    private nonisolated func refreshTask(
        from model: UserJacsimModel,
        now: Date
    ) -> Domain.Task {
        mapToDomainModel(model).refreshingStageProgress(now: now)
    }

    private nonisolated func shouldPersistRefresh(
        _ task: Domain.Task,
        over model: UserJacsimModel
    ) -> Bool {
        model.isDone != task.isTerminallyDone ||
            model.isSuccess != task.isTerminallySuccessful ||
            model.statusRaw != (
                task.isTerminallyDone
                    ? Domain.ChallengeStatus.done.rawValue
                    : Domain.ChallengeStatus.inProgress.rawValue
            ) ||
            model.resultRaw != resultRaw(for: task) ||
            model.currentStageTypeRaw != task.stages.last?.stageTypeRaw ||
            model.stages.map(\.successDays) != task.stages.map(\.successDays) ||
            model.stages.map(\.resultRaw) != task.stages.map(\.resultRaw)
    }

    private nonisolated func resultRaw(for task: Domain.Task) -> String {
        switch task.stages.last?.result ?? .inProgress {
        case .inProgress:
            return Domain.ChallengeResult.none.rawValue
        case .success:
            return Domain.ChallengeResult.success.rawValue
        case .fail:
            return Domain.ChallengeResult.fail.rawValue
        }
    }
}
