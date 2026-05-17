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
        let visibilityByPostID = try fetchVisibilityByPostID(in: context)

        return posts
            .map { post in
                mapToDomainModel(
                    post,
                    cheers: cheers,
                    comments: comments,
                    visibility: visibilityByPostID[post.id] ?? .private
                )
            }
            .filter { post in
                let relation = viewerRelation(viewerID: userID, ownerID: post.authorId, follows: follow)
                return canView(.bragPost, relation: relation, taskVisibility: post.visibility)
            }
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
        try upsertVisibility(postID: post.id.rawValue, visibility: post.visibility, in: context)
        try context.save()
    }

    public func fetchPosts(authorID: UserID) async throws -> [Domain.BragPost] {
        let context = ModelContext(container)
        let posts = try context.fetch(FetchDescriptor<BragPostModel>())
        let cheers = try context.fetch(FetchDescriptor<CheerModel>())
        let comments = try context.fetch(FetchDescriptor<CommentModel>())
        let visibilityByPostID = try fetchVisibilityByPostID(in: context)

        return posts
            .filter { $0.authorId == authorID.rawValue }
            .map { post in
                mapToDomainModel(
                    post,
                    cheers: cheers,
                    comments: comments,
                    visibility: visibilityByPostID[post.id] ?? .private
                )
            }
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func deletePost(id: BragPostID) async throws {
        let context = ModelContext(container)
        let posts = try context.fetch(FetchDescriptor<BragPostModel>())
        guard let post = posts.first(where: { $0.id == id.rawValue }) else { return }
        context.delete(post)
        let visibilities = try context.fetch(FetchDescriptor<BragPostVisibilityModel>())
        for visibility in visibilities where visibility.postId == id.rawValue {
            context.delete(visibility)
        }
        try context.save()
    }

    private func fetchVisibilityByPostID(in context: ModelContext) throws -> [UUID: TaskVisibility] {
        let visibilities = try context.fetch(FetchDescriptor<BragPostVisibilityModel>())
        return Dictionary(
            uniqueKeysWithValues: visibilities.map {
                ($0.postId, TaskVisibility(rawValue: $0.visibilityRaw) ?? .private)
            }
        )
    }

    private func upsertVisibility(
        postID: UUID,
        visibility: TaskVisibility,
        in context: ModelContext
    ) throws {
        let visibilities = try context.fetch(FetchDescriptor<BragPostVisibilityModel>())
        if let existing = visibilities.first(where: { $0.postId == postID }) {
            existing.visibilityRaw = visibility.rawValue
        } else {
            context.insert(BragPostVisibilityModel(postId: postID, visibilityRaw: visibility.rawValue))
        }
    }

    private nonisolated func viewerRelation(
        viewerID: UserID,
        ownerID: UserID,
        follows: [Domain.Follow]
    ) -> ViewerRelation {
        if viewerID == ownerID {
            return .owner
        }

        let pair = follows.filter { follow in
            (follow.fromUserId == viewerID && follow.toUserId == ownerID) ||
                (follow.fromUserId == ownerID && follow.toUserId == viewerID)
        }

        if pair.contains(where: { $0.state == .blocked }) {
            return .blocked
        }

        let accepted = pair.filter { $0.state == .accepted }
        guard !accepted.isEmpty else {
            return .stranger
        }

        let hasForward = accepted.contains { $0.fromUserId == viewerID && $0.toUserId == ownerID }
        let hasReverse = accepted.contains { $0.fromUserId == ownerID && $0.toUserId == viewerID }
        return hasForward && hasReverse || accepted.contains(where: \.isMutual) ? .mutual : .oneWay
    }
}
