import Domain
import Foundation
import SwiftData

public actor CheerRepositoryAdapter {
    private let container: ModelContainer

    public init(container: ModelContainer = SwiftDataStack.shared.container) {
        self.container = container
    }

    public func addUnique(postId: BragPostID, userId: UserID) async throws {
        let context = ModelContext(container)
        let cheers = try context.fetch(FetchDescriptor<CheerModel>())
        let exists = cheers.contains {
            $0.postId == postId.rawValue && $0.userId == userId.rawValue
        }
        guard !exists else { return }

        let cheer = CheerModel(postId: postId.rawValue, userId: userId.rawValue)
        if let post = try context.fetch(FetchDescriptor<BragPostModel>())
            .first(where: { $0.id == postId.rawValue }) {
            post.cheers.append(cheer)
        }
        context.insert(cheer)
        try context.save()
    }

    public func fetchCheers(postId: BragPostID) async throws -> [Domain.Cheer] {
        let context = ModelContext(container)
        return try context.fetch(FetchDescriptor<CheerModel>())
            .filter { $0.postId == postId.rawValue }
            .map(mapToDomainModel(_:))
            .sorted { $0.createdAt < $1.createdAt }
    }
}
