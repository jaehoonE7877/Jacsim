import Foundation

public struct FollowID: Sendable, Codable, Hashable, Identifiable {
    public let rawValue: UUID

    public init(_ rawValue: UUID) {
        self.rawValue = rawValue
    }

    public var id: UUID { rawValue }
}

public enum FollowState: String, Codable, Sendable, CaseIterable {
    case pending
    case accepted
    case rejected
    case blocked
}

public struct Follow: Codable, Sendable, Identifiable, Hashable {
    public let id: FollowID
    public var fromUserId: UserID
    public var toUserId: UserID
    public var state: FollowState
    public var requestedAt: Date
    public var respondedAt: Date?
    public var isMutual: Bool

    public init(
        id: FollowID,
        fromUserId: UserID,
        toUserId: UserID,
        state: FollowState,
        requestedAt: Date = .now,
        respondedAt: Date? = nil,
        isMutual: Bool = false
    ) {
        self.id = id
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.state = state
        self.requestedAt = requestedAt
        self.respondedAt = respondedAt
        self.isMutual = isMutual
    }
}
