import Foundation
import SwiftData
import Domain
import Ports

public actor SwiftDataTaskRepositoryAdapter {
    private let container: ModelContainer
    
    public init(container: ModelContainer = SwiftDataStack.shared.container) {
        self.container = container
    }
    
    public func fetchActiveTasks() async -> [Domain.Task] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<UserJacsimModel>()
        let results = (try? context.fetch(descriptor)) ?? []
        return results
            .filter { !$0.isDone }
            .sorted { $0.startDate < $1.startDate }
            .map(mapToDomainModel)
    }
    
    public func fetchTask(id: TaskID) async -> Domain.Task? {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<UserJacsimModel>()
        return (try? context.fetch(descriptor))?
            .first(where: { $0.id == id.rawValue })
            .map(mapToDomainModel)
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
            .first(where: { $0.id == task.id.rawValue }) else { return }
        let _ = mapToSwiftDataModel(task, existing: existing)
        try context.save()
    }
    
    public func deleteTask(id: TaskID) async throws {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<UserJacsimModel>()
        guard let model = (try? context.fetch(descriptor))?
            .first(where: { $0.id == id.rawValue }) else { return }
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
            let successes = results.filter { $0.isDone && $0.isSuccess }
            let failures = results.filter { $0.isDone && !$0.isSuccess }
            return (successes + failures)
                .sorted { $0.startDate < $1.startDate }
                .map(mapToDomainModel)
        }
    }
}
