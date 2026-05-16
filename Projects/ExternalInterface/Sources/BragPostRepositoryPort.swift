import struct Domain.BragPost
import struct Domain.BragPostID
import struct Domain.Follow
import struct Domain.UserID

public struct BragPostRepositoryPort: Sendable {
    public var fetchFeed: @Sendable (UserID, [Follow]) async throws -> [BragPost]
    public var fetchPosts: @Sendable (UserID) async throws -> [BragPost]
    public var createPost: @Sendable (BragPost) async throws -> Void
    public var deletePost: @Sendable (BragPostID) async throws -> Void

    public init(
        fetchFeed: @escaping @Sendable (UserID, [Follow]) async throws -> [BragPost],
        fetchPosts: @escaping @Sendable (UserID) async throws -> [BragPost] = { _ in [] },
        createPost: @escaping @Sendable (BragPost) async throws -> Void,
        deletePost: @escaping @Sendable (BragPostID) async throws -> Void
    ) {
        self.fetchFeed = fetchFeed
        self.fetchPosts = fetchPosts
        self.createPost = createPost
        self.deletePost = deletePost
    }
}
