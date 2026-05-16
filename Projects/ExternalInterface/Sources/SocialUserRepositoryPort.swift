import struct Domain.User
import struct Domain.UserID

public struct SocialUserRepositoryPort: Sendable {
    public var fetchUser: @Sendable (UserID) async throws -> User?
    public var fetchUserByHandle: @Sendable (String) async throws -> User?
    public var searchUsers: @Sendable (String) async throws -> [User]
    public var upsertUser: @Sendable (User) async throws -> Void

    public init(
        fetchUser: @escaping @Sendable (UserID) async throws -> User?,
        fetchUserByHandle: @escaping @Sendable (String) async throws -> User?,
        searchUsers: @escaping @Sendable (String) async throws -> [User] = { _ in [] },
        upsertUser: @escaping @Sendable (User) async throws -> Void
    ) {
        self.fetchUser = fetchUser
        self.fetchUserByHandle = fetchUserByHandle
        self.searchUsers = searchUsers
        self.upsertUser = upsertUser
    }
}
