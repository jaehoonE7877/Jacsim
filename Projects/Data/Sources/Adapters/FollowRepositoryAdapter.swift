import Domain
import Foundation
import SwiftData

public actor FollowRepositoryAdapter {
    private let container: ModelContainer

    public init(container: ModelContainer = SwiftDataStack.shared.container) {
        self.container = container
    }

    public func fetchPendingRequests(for userID: UserID) async throws -> [Domain.Follow] {
        let context = ModelContext(container)
        let follows = try context.fetch(FetchDescriptor<FollowModel>())
        return follows
            .filter { $0.toUserId == userID.rawValue && $0.stateRaw == FollowState.pending.rawValue }
            .map { mapToDomainModel($0, allFollows: follows) }
            .sorted { $0.requestedAt < $1.requestedAt }
    }

    public func fetchAccepted(for userID: UserID) async throws -> [Domain.Follow] {
        let context = ModelContext(container)
        let follows = try context.fetch(FetchDescriptor<FollowModel>())
        return follows
            .filter {
                $0.stateRaw == FollowState.accepted.rawValue &&
                    ($0.fromUserId == userID.rawValue || $0.toUserId == userID.rawValue)
            }
            .map { mapToDomainModel($0, allFollows: follows) }
            .sorted { $0.requestedAt < $1.requestedAt }
    }

    public func fetchAll(for userID: UserID) async throws -> [Domain.Follow] {
        let context = ModelContext(container)
        let follows = try context.fetch(FetchDescriptor<FollowModel>())
        return follows
            .filter { $0.fromUserId == userID.rawValue || $0.toUserId == userID.rawValue }
            .map { mapToDomainModel($0, allFollows: follows) }
            .sorted { $0.requestedAt < $1.requestedAt }
    }

    public func upsertFollow(_ follow: Domain.Follow) async throws {
        let context = ModelContext(container)
        let follows = try context.fetch(FetchDescriptor<FollowModel>())
        let existing = follows.first { $0.id == follow.id.rawValue }
        let model = mapToSwiftDataModel(follow, existing: existing)
        if existing == nil {
            context.insert(model)
        }
        try context.save()
    }
}
