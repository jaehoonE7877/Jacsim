import struct Domain.FollowChallenge
import struct Domain.UserID

public struct FollowChallengeRepositoryPort: Sendable {
    public var recordFollowChallenge: @Sendable (FollowChallenge) async throws -> Void
    public var fetchByCopier: @Sendable (UserID) async throws -> [FollowChallenge]

    public init(
        recordFollowChallenge: @escaping @Sendable (FollowChallenge) async throws -> Void,
        fetchByCopier: @escaping @Sendable (UserID) async throws -> [FollowChallenge]
    ) {
        self.recordFollowChallenge = recordFollowChallenge
        self.fetchByCopier = fetchByCopier
    }
}
