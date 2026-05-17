import Foundation

public struct FollowChallengeID: Sendable, Codable, Hashable, Identifiable {
    public let rawValue: UUID

    public init(_ rawValue: UUID) {
        self.rawValue = rawValue
    }

    public var id: UUID { rawValue }
}

public struct FollowChallenge: Codable, Sendable, Identifiable, Hashable {
    public let id: FollowChallengeID
    public var originalTaskId: TaskID
    public var copierUserId: UserID
    public var copiedTaskId: TaskID
    public var copiedAt: Date

    public init(
        id: FollowChallengeID,
        originalTaskId: TaskID,
        copierUserId: UserID,
        copiedTaskId: TaskID,
        copiedAt: Date = .now
    ) {
        self.id = id
        self.originalTaskId = originalTaskId
        self.copierUserId = copierUserId
        self.copiedTaskId = copiedTaskId
        self.copiedAt = copiedAt
    }
}
