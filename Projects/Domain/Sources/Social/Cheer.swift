import Foundation

public struct CheerID: Sendable, Codable, Hashable, Identifiable {
    public let rawValue: UUID

    public init(_ rawValue: UUID) {
        self.rawValue = rawValue
    }

    public var id: UUID { rawValue }
}

public struct Cheer: Codable, Sendable, Identifiable, Hashable {
    public let id: CheerID
    public var postId: BragPostID
    public var userId: UserID
    public var createdAt: Date

    public init(
        id: CheerID,
        postId: BragPostID,
        userId: UserID,
        createdAt: Date = .now
    ) {
        self.id = id
        self.postId = postId
        self.userId = userId
        self.createdAt = createdAt
    }
}
