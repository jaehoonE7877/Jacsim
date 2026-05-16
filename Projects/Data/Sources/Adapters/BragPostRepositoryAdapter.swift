import Domain
import Foundation
import SwiftData

public actor BragPostRepositoryAdapter {
    private let container: ModelContainer

    public init(container: ModelContainer = SwiftDataStack.shared.container) {
        self.container = container
    }

    public func fetchFeed(for userID: UserID, follow: [Domain.Follow]) async throws -> [Domain.BragPost] {
        let context = ModelContext(container)
        let posts = try context.fetch(FetchDescriptor<BragPostModel>())
        let cheers = try context.fetch(FetchDescriptor<CheerModel>())
        let comments = try context.fetch(FetchDescriptor<CommentModel>())
        let visibleAuthorIDs = feedAuthorIDs(for: userID, follow: follow)

        return posts
            .filter { visibleAuthorIDs.contains($0.authorId) }
            .map { mapToDomainModel($0, cheers: cheers, comments: comments) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func createPost(_ post: Domain.BragPost) async throws {
        let context = ModelContext(container)
        let posts = try context.fetch(FetchDescriptor<BragPostModel>())
        let existing = posts.first { $0.id == post.id.rawValue }
        let model = mapToSwiftDataModel(post, existing: existing)
        if existing == nil {
            context.insert(model)
        }
        try context.save()
    }

    public func deletePost(id: BragPostID) async throws {
        let context = ModelContext(container)
        let posts = try context.fetch(FetchDescriptor<BragPostModel>())
        guard let post = posts.first(where: { $0.id == id.rawValue }) else { return }
        context.delete(post)
        try context.save()
    }

    private nonisolated func feedAuthorIDs(
        for userID: UserID,
        follow: [Domain.Follow]
    ) -> Set<UUID> {
        var authorIDs = Set([userID.rawValue])
        for relation in follow where relation.state == .accepted {
            if relation.fromUserId == userID {
                authorIDs.insert(relation.toUserId.rawValue)
            }
            if relation.toUserId == userID {
                authorIDs.insert(relation.fromUserId.rawValue)
            }
        }
        return authorIDs
    }
}
