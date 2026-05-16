import struct Domain.BragPost
import struct Domain.BragPostID
import struct Domain.Follow
import struct Domain.UserID

public struct BragPostRepositoryPort: Sendable {
    public var fetchFeed: @Sendable (UserID, [Follow]) async throws -> [BragPost]
    public var createPost: @Sendable (BragPost) async throws -> Void
    public var deletePost: @Sendable (BragPostID) async throws -> Void

    public init(
        fetchFeed: @escaping @Sendable (UserID, [Follow]) async throws -> [BragPost],
        createPost: @escaping @Sendable (BragPost) async throws -> Void,
        deletePost: @escaping @Sendable (BragPostID) async throws -> Void
    ) {
        self.fetchFeed = fetchFeed
        self.createPost = createPost
        self.deletePost = deletePost
    }
}
