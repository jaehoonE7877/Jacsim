import Foundation
import SwiftData

// Historical social schema kept for existing-install SwiftData migration.
extension JacsimSchemaV2 {
    @Model
    public final class UserModel {
        @Attribute(.unique) public var id: UUID
        @Attribute(.unique) public var handle: String
        public var displayName: String
        public var bio: String?
        public var avatarPath: String?
        public var createdAt: Date

        public init(
            id: UUID = UUID(),
            handle: String,
            displayName: String,
            bio: String? = nil,
            avatarPath: String? = nil,
            createdAt: Date = Date()
        ) {
            self.id = id
            self.handle = handle
            self.displayName = displayName
            self.bio = bio
            self.avatarPath = avatarPath
            self.createdAt = createdAt
        }
    }

    @Model
    public final class FollowModel {
        @Attribute(.unique) public var id: UUID
        public var fromUserId: UUID
        public var toUserId: UUID
        public var stateRaw: String
        public var requestedAt: Date
        public var respondedAt: Date?
        @Transient public var hasAcceptedReverseFollow: Bool = false

        public var isMutual: Bool {
            stateRaw == "accepted" && hasAcceptedReverseFollow
        }

        public init(
            id: UUID = UUID(),
            fromUserId: UUID,
            toUserId: UUID,
            stateRaw: String = "pending",
            requestedAt: Date = Date(),
            respondedAt: Date? = nil
        ) {
            self.id = id
            self.fromUserId = fromUserId
            self.toUserId = toUserId
            self.stateRaw = stateRaw
            self.requestedAt = requestedAt
            self.respondedAt = respondedAt
        }

        public func isMutual(in follows: [FollowModel]) -> Bool {
            stateRaw == "accepted" && follows.contains { follow in
                follow.fromUserId == toUserId &&
                    follow.toUserId == fromUserId &&
                    follow.stateRaw == "accepted"
            }
        }
    }

    @Model
    public final class BragPostModel {
        @Attribute(.unique) public var id: UUID
        public var authorId: UUID
        public var taskId: UUID?
        public var typeRaw: String
        public var body: String
        public var recordImagePaths: [String]
        public var createdAt: Date

        @Relationship(deleteRule: .cascade)
        public var cheers: [CheerModel]

        @Relationship(deleteRule: .cascade)
        public var comments: [CommentModel]

        public init(
            id: UUID = UUID(),
            authorId: UUID,
            taskId: UUID? = nil,
            typeRaw: String,
            body: String,
            recordImagePaths: [String] = [],
            createdAt: Date = Date(),
            cheers: [CheerModel] = [],
            comments: [CommentModel] = []
        ) {
            self.id = id
            self.authorId = authorId
            self.taskId = taskId
            self.typeRaw = typeRaw
            self.body = body
            self.recordImagePaths = Array(recordImagePaths.prefix(4))
            self.createdAt = createdAt
            self.cheers = cheers
            self.comments = comments
        }
    }

    @Model
    public final class CheerModel {
        @Attribute(.unique) public var id: UUID
        public var postId: UUID
        public var userId: UUID
        public var createdAt: Date

        public init(
            id: UUID = UUID(),
            postId: UUID,
            userId: UUID,
            createdAt: Date = Date()
        ) {
            self.id = id
            self.postId = postId
            self.userId = userId
            self.createdAt = createdAt
        }
    }

    @Model
    public final class CommentModel {
        @Attribute(.unique) public var id: UUID
        public var postId: UUID
        public var authorId: UUID
        public var body: String
        public var createdAt: Date
        public var parentCommentId: UUID?

        public init(
            id: UUID = UUID(),
            postId: UUID,
            authorId: UUID,
            body: String,
            createdAt: Date = Date(),
            parentCommentId: UUID? = nil
        ) {
            self.id = id
            self.postId = postId
            self.authorId = authorId
            self.body = body
            self.createdAt = createdAt
            self.parentCommentId = parentCommentId
        }
    }

    @Model
    public final class FollowChallengeModel {
        @Attribute(.unique) public var id: UUID
        public var originalTaskId: UUID
        public var copierUserId: UUID
        public var copiedTaskId: UUID
        public var copiedAt: Date

        public init(
            id: UUID = UUID(),
            originalTaskId: UUID,
            copierUserId: UUID,
            copiedTaskId: UUID,
            copiedAt: Date = Date()
        ) {
            self.id = id
            self.originalTaskId = originalTaskId
            self.copierUserId = copierUserId
            self.copiedTaskId = copiedTaskId
            self.copiedAt = copiedAt
        }
    }
}
