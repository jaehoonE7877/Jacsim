import Domain
import Foundation
import Observation

public enum FeedMode: String, CaseIterable, Identifiable {
    case following
    case recommended

    public var id: String { rawValue }

    var title: String {
        switch self {
        case .following:
            return "팔로잉"
        case .recommended:
            return "추천"
        }
    }
}

public struct FeedPostItem: Identifiable {
    public let post: Domain.BragPost
    public let author: Domain.User
    public let relation: ViewerRelation
    public let taskTitle: String?
    public let taskVisibility: TaskVisibility?
    public let currentUserID: UserID

    public var id: UUID { post.id.rawValue }
    public var isOwn: Bool { post.authorId == currentUserID }
    public var hasCheered: Bool { post.cheers.contains { $0.userId == currentUserID } }
}

@MainActor
@Observable
public final class FeedModel {
    public var mode: FeedMode = .following
    public var posts: [FeedPostItem] = []
    public var visibleLimit: Int = 20
    public var isLoading: Bool = false
    public var isRefreshing: Bool = false
    public var loadFailed: Bool = false
    public var toastMessage: String?
    public var isComposerPresented: Bool = false
    public var selectedCommentPost: FeedPostItem?
    public var commentDraft: String = ""

    @ObservationIgnored public let dependencies: JacsimDependencies
    @ObservationIgnored public var onFollowChallengePrefill: (String) -> Void = { _ in }
    @ObservationIgnored private var loadTask: _Concurrency.Task<Void, Never>?

    private let currentUserID = SocialLocalSession.currentUserID

    public init(dependencies: JacsimDependencies) {
        self.dependencies = dependencies
    }

    deinit {
        loadTask?.cancel()
    }

    public var visiblePosts: [FeedPostItem] {
        let filtered: [FeedPostItem]
        switch mode {
        case .following:
            filtered = posts.filter { $0.relation != .stranger || $0.isOwn }
        case .recommended:
            filtered = posts
        }
        return Array(filtered.prefix(visibleLimit))
    }

    public func onAppear() {
        guard posts.isEmpty else { return }
        load()
    }

    public func load() {
        isLoading = posts.isEmpty
        isRefreshing = !posts.isEmpty
        loadFailed = false
        loadTask?.cancel()
        loadTask = _Concurrency.Task { [dependencies, currentUserID] in
            do {
                let accepted = try await dependencies.followRepository.fetchAccepted(currentUserID)
                let allFollows = try await dependencies.followRepository.fetchAll(currentUserID)
                let feedPosts = try await dependencies.bragPostRepository.fetchFeed(currentUserID, accepted)
                var items: [FeedPostItem] = []

                for post in feedPosts {
                    let relation = SocialVisibilitySupport.relation(
                        viewerID: currentUserID,
                        ownerID: post.authorId,
                        follows: allFollows
                    )
                    guard canView(.bragPost, relation: relation, taskVisibility: nil) else { continue }
                    guard let author = try await dependencies.socialUserRepository.fetchUser(post.authorId) else { continue }
                    let task: Domain.Task?
                    if let taskID = post.taskId {
                        task = try await dependencies.taskQueryClient.fetchTask(taskID)
                    } else {
                        task = nil
                    }
                    items.append(
                        FeedPostItem(
                            post: post,
                            author: author,
                            relation: relation,
                            taskTitle: task?.title,
                            taskVisibility: task?.visibility,
                            currentUserID: currentUserID
                        )
                    )
                }

                feedResponse(items)
            } catch is CancellationError {
                return
            } catch {
                feedFailed()
            }
        }
    }

    public func refresh() async {
        load()
    }

    public func loadNextPageIfNeeded(current item: FeedPostItem) {
        guard visiblePosts.last?.id == item.id else { return }
        visibleLimit += 20
    }

    public func composerButtonTapped() {
        isComposerPresented = true
    }

    public func composerCompleted() {
        isComposerPresented = false
        toastMessage = "공유되었어요"
        load()
    }

    public func cheerTapped(_ item: FeedPostItem) {
        _Concurrency.Task { [dependencies, currentUserID] in
            do {
                let inserted = try await dependencies.cheerRepository.addUnique(item.post.id, currentUserID)
                if inserted {
                    load()
                } else {
                    toastMessage = "이미 응원했어요"
                }
            } catch {
                toastMessage = "응원하지 못했어요"
            }
        }
    }

    public func commentTapped(_ item: FeedPostItem) {
        guard canView(.commentList, relation: item.relation, taskVisibility: item.taskVisibility) else {
            toastMessage = "댓글을 볼 수 없어요"
            return
        }
        selectedCommentPost = item
        commentDraft = ""
    }

    public func addComment() {
        guard let item = selectedCommentPost else { return }
        let body = commentDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !body.isEmpty else { return }

        _Concurrency.Task { [dependencies, currentUserID] in
            do {
                try await dependencies.commentRepository.addComment(
                    Domain.Comment(
                        id: CommentID(UUID()),
                        postId: item.post.id,
                        authorId: currentUserID,
                        body: body
                    )
                )
                commentDraft = ""
                load()
            } catch {
                toastMessage = "댓글을 저장하지 못했어요"
            }
        }
    }

    public func followChallengeTapped(_ item: FeedPostItem) {
        let originalTaskID = item.post.taskId ?? TaskID(item.post.id.rawValue)
        let copiedTaskID = TaskID(UUID())
        _Concurrency.Task { [dependencies, currentUserID] in
            do {
                try await dependencies.followChallengeRepository.recordFollowChallenge(
                    FollowChallenge(
                        id: FollowChallengeID(UUID()),
                        originalTaskId: originalTaskID,
                        copierUserId: currentUserID,
                        copiedTaskId: copiedTaskID
                    )
                )
                onFollowChallengePrefill(item.taskTitle ?? item.post.body)
            } catch {
                toastMessage = "따라하기를 시작하지 못했어요"
            }
        }
    }

    public func deleteTapped(_ item: FeedPostItem) {
        guard item.isOwn else { return }
        _Concurrency.Task { [dependencies] in
            do {
                try await dependencies.bragPostRepository.deletePost(item.post.id)
                load()
            } catch {
                toastMessage = "삭제하지 못했어요"
            }
        }
    }

    public func dismissToast() {
        toastMessage = nil
    }

    private func feedResponse(_ items: [FeedPostItem]) {
        posts = items
        isLoading = false
        isRefreshing = false
        loadFailed = false
    }

    private func feedFailed() {
        isLoading = false
        isRefreshing = false
        loadFailed = true
    }
}
