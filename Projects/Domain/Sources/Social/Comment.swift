import Foundation

public struct CommentID: Sendable, Codable, Hashable, Identifiable {
    public let rawValue: UUID

    public init(_ rawValue: UUID) {
        self.rawValue = rawValue
    }

    public var id: UUID { rawValue }
}

public struct Comment: Codable, Sendable, Identifiable, Hashable {
    public let id: CommentID
    public var postId: BragPostID
    public var authorId: UserID
    public var body: String
    public var createdAt: Date
    public var parentCommentId: CommentID?

    public init(
        id: CommentID,
        postId: BragPostID,
        authorId: UserID,
        body: String,
        createdAt: Date = .now,
        parentCommentId: CommentID? = nil
    ) {
        self.id = id
        self.postId = postId
        self.authorId = authorId
        self.body = body
        self.createdAt = createdAt
        self.parentCommentId = parentCommentId
    }
}
