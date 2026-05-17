import Foundation

public struct BragPostID: Sendable, Codable, Hashable, Identifiable {
    public let rawValue: UUID

    public init(_ rawValue: UUID) {
        self.rawValue = rawValue
    }

    public var id: UUID { rawValue }
}

public enum BragType: String, Codable, Sendable, CaseIterable {
    case graduation
    case streak
    case completion
}

public struct BragPost: Codable, Sendable, Identifiable, Hashable {
    public let id: BragPostID
    public var authorId: UserID
    public var taskId: TaskID?
    public var type: BragType
    public var body: String
    public var recordImagePaths: [String]
    public var visibility: TaskVisibility
    public var createdAt: Date
    public var cheers: [Cheer]
    public var comments: [Comment]

    public init(
        id: BragPostID,
        authorId: UserID,
        taskId: TaskID? = nil,
        type: BragType,
        body: String,
        recordImagePaths: [String] = [],
        visibility: TaskVisibility = .private,
        createdAt: Date = .now,
        cheers: [Cheer] = [],
        comments: [Comment] = []
    ) {
        self.id = id
        self.authorId = authorId
        self.taskId = taskId
        self.type = type
        self.body = body
        self.recordImagePaths = Array(recordImagePaths.prefix(4))
        self.visibility = visibility
        self.createdAt = createdAt
        self.cheers = cheers
        self.comments = comments
    }
}
