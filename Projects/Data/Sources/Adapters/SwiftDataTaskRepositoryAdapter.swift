import Foundation
import SwiftData
import Domain
import Ports

public enum TaskRepositoryAdapterError: Error {
    case taskNotFound(TaskID)
    case fetchFailed(String)
    case saveFailed(String)
}

public actor SwiftDataTaskRepositoryAdapter {
    private let container: ModelContainer
    
    public init(container: ModelContainer = SwiftDataStack.shared.container) {
        self.container = container
    }

    public nonisolated func makePort() -> TaskRepositoryPort {
        let adapter = self

        return TaskRepositoryPort(
            fetchActiveTasks: { try await adapter.fetchActiveTasks() },
            fetchTask: { try await adapter.fetchTask(id: $0) },
            addTask: { try await adapter.addTask($0) },
            updateTask: { try await adapter.updateTask($0) },
            deleteTask: { try await adapter.deleteTask(id: $0) },
            fetchTasksByStatus: { try await adapter.fetchTasksByStatus($0) }
        )
    }
    
    public func fetchActiveTasks() async throws -> [Domain.Task] {
        let tasks = try await fetchMappedTasks()
        return sortTasks(tasks.filter(isActiveTask))
    }
    
    public func fetchTask(id: TaskID) async throws -> Domain.Task? {
        let context = ModelContext(container)
        return try fetchPersistedTasks(in: context)
            .first(where: { $0.id == id.rawValue })
            .map(mapToDomainModel)
    }
    
    public func addTask(_ task: Domain.Task) async throws {
        let context = ModelContext(container)
        let model = mapToSwiftDataModel(task)
        context.insert(model)
        do {
            try context.save()
        } catch {
            throw TaskRepositoryAdapterError.saveFailed(error.localizedDescription)
        }
    }
    
    public func updateTask(_ task: Domain.Task) async throws {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<UserJacsimModel>()
        let fetched: [UserJacsimModel]
        do {
            fetched = try context.fetch(descriptor)
        } catch {
            throw TaskRepositoryAdapterError.fetchFailed(error.localizedDescription)
        }
        guard let existing = fetched.first(where: { $0.id == task.id.rawValue }) else {
            throw TaskRepositoryAdapterError.taskNotFound(task.id)
        }
        let _ = mapToSwiftDataModel(task, existing: existing)
        do {
            try context.save()
        } catch {
            throw TaskRepositoryAdapterError.saveFailed(error.localizedDescription)
        }
    }
    
    public func deleteTask(id: TaskID) async throws {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<UserJacsimModel>()
        let fetched: [UserJacsimModel]
        do {
            fetched = try context.fetch(descriptor)
        } catch {
            throw TaskRepositoryAdapterError.fetchFailed(error.localizedDescription)
        }
        guard let model = fetched.first(where: { $0.id == id.rawValue }) else {
            throw TaskRepositoryAdapterError.taskNotFound(id)
        }
        context.delete(model)
        do {
            try context.save()
        } catch {
            throw TaskRepositoryAdapterError.saveFailed(error.localizedDescription)
        }
    }
    
    public func fetchTasksByStatus(_ status: ChallengeStatus) async throws -> [Domain.Task] {
        switch status {
        case .inProgress:
            return try await fetchActiveTasks()
        case .done:
            let tasks = try await fetchMappedTasks()
            return sortTasks(tasks.filter(isDoneTask))
        }
    }
}

private extension SwiftDataTaskRepositoryAdapter {
    func fetchPersistedTasks(in context: ModelContext) throws -> [UserJacsimModel] {
        let descriptor = FetchDescriptor<UserJacsimModel>()
        do {
            return try context.fetch(descriptor)
        } catch {
            throw TaskRepositoryAdapterError.fetchFailed(error.localizedDescription)
        }
    }

    func fetchMappedTasks() async throws -> [Domain.Task] {
        let context = ModelContext(container)
        return try fetchPersistedTasks(in: context).map(mapToDomainModel)
    }

    func sortTasks(_ tasks: [Domain.Task]) -> [Domain.Task] {
        tasks.sorted { $0.startDate < $1.startDate }
    }

    func isActiveTask(_ task: Domain.Task) -> Bool {
        task.stages.last?.result == .inProgress
    }

    func isDoneTask(_ task: Domain.Task) -> Bool {
        switch task.stages.last?.result {
        case .success, .fail:
            return true
        case .inProgress, .none:
            return false
        }
    }
}
