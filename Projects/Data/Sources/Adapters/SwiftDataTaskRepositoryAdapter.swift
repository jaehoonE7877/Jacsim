import Foundation
import SwiftData
import Domain
import ExternalInterface

public actor SwiftDataTaskRepositoryAdapter {
    private let context: ModelContext
    
    public init(context: ModelContext = SwiftDataStack.shared.context) {
        self.context = context
    }
    
    public func fetchActiveTasks() async -> [Domain.Task] {
        let descriptor = FetchDescriptor<UserJacsimModel>(
            predicate: #Predicate { $0.isDone == false },
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        let results = (try? context.fetch(descriptor)) ?? []
        return results.map(mapToDomainModel)
    }
    
    public func fetchTask(id: TaskID) async -> Domain.Task? {
        let descriptor = FetchDescriptor<UserJacsimModel>(
            predicate: #Predicate { $0.id == id.rawValue }
        )
        return (try? context.fetch(descriptor))?.first.map(mapToDomainModel)
    }
    
    public func addTask(_ task: Domain.Task) async throws {
        let model = mapToSwiftDataModel(task)
        context.insert(model)
        try context.save()
    }
    
    public func updateTask(_ task: Domain.Task) async throws {
        let descriptor = FetchDescriptor<UserJacsimModel>(
            predicate: #Predicate { $0.id == task.id.rawValue }
        )
        guard let existing = (try? context.fetch(descriptor))?.first else { return }
        let _ = mapToSwiftDataModel(task, existing: existing)
        try context.save()
    }
    
    public func deleteTask(id: TaskID) async throws {
        let descriptor = FetchDescriptor<UserJacsimModel>(
            predicate: #Predicate { $0.id == id.rawValue }
        )
        guard let model = (try? context.fetch(descriptor))?.first else { return }
        context.delete(model)
        try context.save()
    }
    
    public func fetchTasksByStatus(_ status: ChallengeStatus) async -> [Domain.Task] {
        switch status {
        case .inProgress:
            return await fetchActiveTasks()
        case .done:
            let successDescriptor = FetchDescriptor<UserJacsimModel>(
                predicate: #Predicate { $0.isDone == true && $0.isSuccess == true },
                sortBy: [SortDescriptor(\.startDate, order: .forward)]
            )
            let failDescriptor = FetchDescriptor<UserJacsimModel>(
                predicate: #Predicate { $0.isDone == true && $0.isSuccess == false },
                sortBy: [SortDescriptor(\.startDate, order: .forward)]
            )
            let successes = (try? context.fetch(successDescriptor)) ?? []
            let failures = (try? context.fetch(failDescriptor)) ?? []
            return (successes + failures)
                .sorted { $0.startDate < $1.startDate }
                .map(mapToDomainModel)
        }
    }
}
