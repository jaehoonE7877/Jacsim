import struct Domain.Follow
import struct Domain.UserID

public struct FollowRepositoryPort: Sendable {
    public var fetchPendingRequests: @Sendable (UserID) async throws -> [Follow]
    public var fetchAccepted: @Sendable (UserID) async throws -> [Follow]
    public var upsertFollow: @Sendable (Follow) async throws -> Void

    public init(
        fetchPendingRequests: @escaping @Sendable (UserID) async throws -> [Follow],
        fetchAccepted: @escaping @Sendable (UserID) async throws -> [Follow],
        upsertFollow: @escaping @Sendable (Follow) async throws -> Void
    ) {
        self.fetchPendingRequests = fetchPendingRequests
        self.fetchAccepted = fetchAccepted
        self.upsertFollow = upsertFollow
    }
}
