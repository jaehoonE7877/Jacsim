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
    
    public func fetchActiveTasks() async throws -> [Domain.Task] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<UserJacsimModel>()
        let results: [UserJacsimModel]
        do {
            results = try context.fetch(descriptor)
        } catch {
            throw TaskRepositoryAdapterError.fetchFailed(error.localizedDescription)
        }
        return results
            .filter { !$0.isDone }
            .sorted { $0.startDate < $1.startDate }
            .map(mapToDomainModel)
    }
    
    public func fetchTask(id: TaskID) async throws -> Domain.Task? {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<UserJacsimModel>()
        do {
            return try context.fetch(descriptor)
            .first(where: { $0.id == id.rawValue })
            .map(mapToDomainModel)
        } catch {
            throw TaskRepositoryAdapterError.fetchFailed(error.localizedDescription)
        }
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
        let context = ModelContext(container)
        switch status {
        case .inProgress:
            return try await fetchActiveTasks()
        case .done:
            let descriptor = FetchDescriptor<UserJacsimModel>()
            let results: [UserJacsimModel]
            do {
                results = try context.fetch(descriptor)
            } catch {
                throw TaskRepositoryAdapterError.fetchFailed(error.localizedDescription)
            }
            let successes = results.filter { $0.isDone && $0.isSuccess }
            let failures = results.filter { $0.isDone && !$0.isSuccess }
            return (successes + failures)
                .sorted { $0.startDate < $1.startDate }
                .map(mapToDomainModel)
        }
    }
}
