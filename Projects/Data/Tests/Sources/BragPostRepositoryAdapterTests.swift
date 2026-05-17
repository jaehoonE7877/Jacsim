import Domain
import Foundation
import SwiftData
import Testing

@testable import Data

@Test("BragPostRepositoryAdapter는 공개범위에 따라 피드 노출을 필터링한다")
func bragPostRepositoryFiltersFeedByPostVisibility() async throws {
    let adapter = BragPostRepositoryAdapter(container: try makeSocialInMemoryContainer())
    let viewerID = UserID(UUID())
    let friendID = UserID(UUID())
    let strangerID = UserID(UUID())
    let privatePost = Domain.BragPost(
        id: BragPostID(UUID()),
        authorId: friendID,
        type: .completion,
        body: "비공개",
        visibility: .private
    )
    let followersPost = Domain.BragPost(
        id: BragPostID(UUID()),
        authorId: friendID,
        type: .completion,
        body: "친구 공개",
        visibility: .followers
    )
    let publicPost = Domain.BragPost(
        id: BragPostID(UUID()),
        authorId: strangerID,
        type: .completion,
        body: "전체 공개",
        visibility: .public
    )
    try await adapter.createPost(privatePost)
    try await adapter.createPost(followersPost)
    try await adapter.createPost(publicPost)

    let feed = try await adapter.fetchFeed(
        for: viewerID,
        follow: [
            Follow(
                id: FollowID(UUID()),
                fromUserId: viewerID,
                toUserId: friendID,
                state: .accepted
            )
        ]
    )

    #expect(feed.map(\.id).contains(privatePost.id) == false)
    #expect(feed.map(\.id).contains(followersPost.id))
    #expect(feed.map(\.id).contains(publicPost.id))
}

private func makeSocialInMemoryContainer() throws -> ModelContainer {
    let schema = Schema(versionedSchema: CurrentSwiftDataSchema.self)
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: [configuration])
}
