import struct Domain.Follow
import struct Domain.UserID

public struct FollowRepositoryPort: Sendable {
    public var fetchPendingRequests: @Sendable (UserID) async throws -> [Follow]
    public var fetchAccepted: @Sendable (UserID) async throws -> [Follow]
    public var fetchAll: @Sendable (UserID) async throws -> [Follow]
    public var upsertFollow: @Sendable (Follow) async throws -> Void

    public init(
        fetchPendingRequests: @escaping @Sendable (UserID) async throws -> [Follow],
        fetchAccepted: @escaping @Sendable (UserID) async throws -> [Follow],
        fetchAll: @escaping @Sendable (UserID) async throws -> [Follow] = { _ in [] },
        upsertFollow: @escaping @Sendable (Follow) async throws -> Void
    ) {
        self.fetchPendingRequests = fetchPendingRequests
        self.fetchAccepted = fetchAccepted
        self.fetchAll = fetchAll
        self.upsertFollow = upsertFollow
    }
}
