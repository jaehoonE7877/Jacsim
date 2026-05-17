import Domain
import Foundation
import SwiftData

public actor FollowChallengeRepositoryAdapter {
    private let container: ModelContainer

    public init(container: ModelContainer = SwiftDataStack.shared.container) {
        self.container = container
    }

    public func recordFollowChallenge(_ followChallenge: Domain.FollowChallenge) async throws {
        let context = ModelContext(container)
        let followChallenges = try context.fetch(FetchDescriptor<FollowChallengeModel>())
        let existing = followChallenges.first { $0.id == followChallenge.id.rawValue }
        let model = mapToSwiftDataModel(followChallenge, existing: existing)
        if existing == nil {
            context.insert(model)
        }
        try context.save()
    }

    public func fetchByCopier(_ userID: UserID) async throws -> [Domain.FollowChallenge] {
        let context = ModelContext(container)
        return try context.fetch(FetchDescriptor<FollowChallengeModel>())
            .filter { $0.copierUserId == userID.rawValue }
            .map(mapToDomainModel(_:))
            .sorted { $0.copiedAt > $1.copiedAt }
    }
}
