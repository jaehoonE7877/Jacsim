import Foundation

public struct UserID: Sendable, Codable, Hashable, Identifiable {
    public let rawValue: UUID

    public init(_ rawValue: UUID) {
        self.rawValue = rawValue
    }

    public var id: UUID { rawValue }
}

public struct User: Codable, Sendable, Identifiable, Hashable {
    public let id: UserID
    public var handle: String
    public var displayName: String
    public var bio: String?
    public var avatarPath: String?
    public var createdAt: Date

    public init(
        id: UserID,
        handle: String,
        displayName: String,
        bio: String? = nil,
        avatarPath: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.handle = handle
        self.displayName = displayName
        self.bio = bio
        self.avatarPath = avatarPath
        self.createdAt = createdAt
    }
}
