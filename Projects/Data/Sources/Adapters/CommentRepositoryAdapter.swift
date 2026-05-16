import Domain
import Foundation
import SwiftData

public actor CommentRepositoryAdapter {
    private let container: ModelContainer

    public init(container: ModelContainer = SwiftDataStack.shared.container) {
        self.container = container
    }

    public func addComment(_ comment: Domain.Comment) async throws {
        let context = ModelContext(container)
        let comments = try context.fetch(FetchDescriptor<CommentModel>())
        let existing = comments.first { $0.id == comment.id.rawValue }
        let model = mapToSwiftDataModel(comment, existing: existing)
        if existing == nil {
            if let post = try context.fetch(FetchDescriptor<BragPostModel>())
                .first(where: { $0.id == comment.postId.rawValue }) {
                post.comments.append(model)
            }
            context.insert(model)
        }
        try context.save()
    }

    public func fetchComments(postId: BragPostID) async throws -> [Domain.Comment] {
        let context = ModelContext(container)
        return try context.fetch(FetchDescriptor<CommentModel>())
            .filter { $0.postId == postId.rawValue }
            .map(mapToDomainModel(_:))
            .sorted { $0.createdAt < $1.createdAt }
    }

    public func deleteComment(id: CommentID) async throws {
        let context = ModelContext(container)
        let comments = try context.fetch(FetchDescriptor<CommentModel>())
        guard let comment = comments.first(where: { $0.id == id.rawValue }) else { return }
        context.delete(comment)
        try context.save()
    }
}
