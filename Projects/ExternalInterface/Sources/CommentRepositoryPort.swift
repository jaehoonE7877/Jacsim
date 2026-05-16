import struct Domain.BragPostID
import struct Domain.Comment
import struct Domain.CommentID

public struct CommentRepositoryPort: Sendable {
    public var addComment: @Sendable (Comment) async throws -> Void
    public var fetchComments: @Sendable (BragPostID) async throws -> [Comment]
    public var deleteComment: @Sendable (CommentID) async throws -> Void

    public init(
        addComment: @escaping @Sendable (Comment) async throws -> Void,
        fetchComments: @escaping @Sendable (BragPostID) async throws -> [Comment],
        deleteComment: @escaping @Sendable (CommentID) async throws -> Void
    ) {
        self.addComment = addComment
        self.fetchComments = fetchComments
        self.deleteComment = deleteComment
    }
}
