import Domain
import ExternalInterface
import Foundation
import Testing
import UIKit

@testable import Jacsim

private actor FollowRecorder {
    private(set) var follows: [Follow] = []

    func record(_ follow: Follow) {
        follows.append(follow)
    }

    func first() -> Follow? {
        follows.first
    }

    func count() -> Int {
        follows.count
    }
}

private actor SocialNotificationRecorder {
    struct Call: Equatable {
        let trigger: SocialNotificationTrigger
        let context: SocialNotificationContext
    }

    private(set) var calls: [Call] = []

    func record(_ trigger: SocialNotificationTrigger, _ context: SocialNotificationContext) {
        calls.append(Call(trigger: trigger, context: context))
    }

    func count() -> Int {
        calls.count
    }
}

private actor FollowChallengeRecorder {
    private(set) var challenges: [FollowChallenge] = []

    func record(_ challenge: FollowChallenge) {
        challenges.append(challenge)
    }

    func first() -> FollowChallenge? {
        challenges.first
    }

    func count() -> Int {
        challenges.count
    }
}

private actor BragPostRecorder {
    private(set) var posts: [Domain.BragPost] = []

    func record(_ post: Domain.BragPost) {
        posts.append(post)
    }

    func first() -> Domain.BragPost? {
        posts.first
    }

    func count() -> Int {
        posts.count
    }
}

private actor ImageSaveRecorder {
    struct SaveCall: Equatable {
        let key: String
        let byteCount: Int
    }

    private(set) var calls: [SaveCall] = []

    func record(key: String, data: Data) {
        calls.append(SaveCall(key: key, byteCount: data.count))
    }

    func first() -> SaveCall? {
        calls.first
    }

    func count() -> Int {
        calls.count
    }
}

private actor CommentStore {
    private(set) var comments: [Domain.Comment] = []

    func add(_ comment: Domain.Comment) {
        comments.append(comment)
    }

    func all() -> [Domain.Comment] {
        comments
    }

    func count() -> Int {
        comments.count
    }
}

@MainActor
@Test("친구 검색 팔로우 요청은 현재 사용자에서 상대 사용자 방향으로 저장한다")
func friendsSearchFollowRequestUsesCurrentUserAsRequester() async {
    let followRecorder = FollowRecorder()
    let notificationRecorder = SocialNotificationRecorder()
    var dependencies = JacsimDependencies.test
    dependencies.followRepository = FollowRepositoryPort(
        fetchPendingRequests: { _ in [] },
        fetchAccepted: { _ in [] },
        fetchAll: { _ in [] },
        upsertFollow: { follow in await followRecorder.record(follow) }
    )
    dependencies.notificationScheduler = makeSocialNotificationScheduler(notificationRecorder)
    let targetUser = Domain.User(id: UserID(UUID()), handle: "friend", displayName: "친구")
    let model = FriendsSearchModel(dependencies: dependencies)

    model.followTapped(FriendSearchRow(user: targetUser, state: .follow))

    await waitUntil { await followRecorder.count() == 1 }
    let follow = await followRecorder.first()
    #expect(follow?.fromUserId == SocialLocalSession.currentUserID)
    #expect(follow?.toUserId == targetUser.id)
    #expect(follow?.state == .pending)
    #expect(await notificationRecorder.count() == 0)
}

@Test("소셜 공개범위 정책은 자랑글/반응/댓글만 작심 공개범위를 따른다")
func socialVisibilityPolicyScopesBragInteractionsToPostVisibility() {
    #expect(canView(.profile, relation: .stranger, taskVisibility: .private))
    #expect(canView(.bragPost, relation: .stranger, taskVisibility: .public))
    #expect(canView(.bragPost, relation: .stranger, taskVisibility: .private) == false)
    #expect(canView(.cheerCount, relation: .oneWay, taskVisibility: .followers))
    #expect(canView(.cheerCount, relation: .stranger, taskVisibility: .followers) == false)
    #expect(canView(.commentList, relation: .mutual, taskVisibility: .followers))
    #expect(canView(.commentList, relation: .stranger, taskVisibility: .followers) == false)
}

@MainActor
@Test("따라하기는 탭 시점이 아니라 실제 작심 생성 성공 후 복사된 task id로 기록한다")
func followChallengeRecordsOnlyAfterCopiedTaskIsCreated() async {
    let challengeRecorder = FollowChallengeRecorder()
    let notificationRecorder = SocialNotificationRecorder()
    var dependencies = JacsimDependencies.test
    dependencies.followChallengeRepository = FollowChallengeRepositoryPort(
        recordFollowChallenge: { challenge in await challengeRecorder.record(challenge) },
        fetchByCopier: { _ in [] }
    )
    dependencies.notificationScheduler = makeSocialNotificationScheduler(notificationRecorder)
    let model = FeedModel(dependencies: dependencies)
    let authorID = UserID(UUID())
    let originalTaskID = TaskID(UUID())
    let post = Domain.BragPost(
        id: BragPostID(UUID()),
        authorId: authorID,
        taskId: originalTaskID,
        type: .completion,
        body: "오늘 인증 완료",
        visibility: .public
    )
    let item = FeedPostItem(
        post: post,
        author: Domain.User(id: authorID, handle: "author", displayName: "작성자"),
        relation: .stranger,
        taskTitle: "원본 작심",
        taskVisibility: .public,
        imageDataItems: [],
        currentUserID: SocialLocalSession.currentUserID
    )
    var capturedDraft: FollowChallengeDraft?
    model.onFollowChallengePrefill = { draft in
        capturedDraft = draft
    }

    model.followChallengeTapped(item)

    #expect(await challengeRecorder.count() == 0)
    guard let draft = capturedDraft else {
        Issue.record("따라하기 초안이 생성되지 않았습니다")
        return
    }
    let copiedTask = makeSocialRegressionTask(id: TaskID(UUID()), title: "원본 작심")
    model.followChallengeCreated(draft, copiedTask: copiedTask)

    await waitUntil { await challengeRecorder.count() == 1 }
    let challenge = await challengeRecorder.first()
    #expect(challenge?.originalTaskId == originalTaskID)
    #expect(challenge?.copiedTaskId == copiedTask.id)
    #expect(challenge?.copierUserId == SocialLocalSession.currentUserID)
    #expect(await notificationRecorder.count() == 0)
}

@MainActor
@Test("자랑글 작성은 공개범위와 실제 선택 이미지를 저장한다")
func bragComposerPersistsSelectedVisibilityAndImage() async {
    let postRecorder = BragPostRecorder()
    let imageRecorder = ImageSaveRecorder()
    let notificationRecorder = SocialNotificationRecorder()
    var dependencies = JacsimDependencies.test
    dependencies.bragPostRepository = BragPostRepositoryPort(
        fetchFeed: { _, _ in [] },
        fetchPosts: { _ in [] },
        createPost: { post in await postRecorder.record(post) },
        deletePost: { _ in }
    )
    dependencies.imageStore = ImageStorePort(
        saveImage: { key, data in
            await imageRecorder.record(key: key, data: data)
            return key
        },
        loadImage: { _ in nil },
        deleteImage: { _ in },
        imageExists: { _ in false }
    )
    dependencies.notificationScheduler = makeSocialNotificationScheduler(notificationRecorder)
    let model = BragComposerModel(dependencies: dependencies)
    model.body = "오늘도 인증 완료"
    model.selectedVisibility = .followers
    model.imageSelected(makeSolidRegressionImage())

    model.submitTapped()

    await waitUntil { await postRecorder.count() == 1 }
    let post = await postRecorder.first()
    let save = await imageRecorder.first()
    #expect(post?.visibility == .followers)
    #expect(post?.recordImagePaths.count == 1)
    #expect(post?.recordImagePaths.first == save?.key)
    #expect((save?.byteCount ?? 0) > 0)
    #expect(await notificationRecorder.count() == 0)
}

@MainActor
@Test("댓글 등록 후 열린 댓글 시트의 선택 post가 최신 댓글 목록으로 갱신된다")
func feedCommentSheetRefreshesSelectedPostAfterAddingComment() async {
    let commentStore = CommentStore()
    let authorID = UserID(UUID())
    let postID = BragPostID(UUID())
    var dependencies = JacsimDependencies.test
    dependencies.followRepository = FollowRepositoryPort(
        fetchPendingRequests: { _ in [] },
        fetchAccepted: { _ in [] },
        fetchAll: { _ in [] },
        upsertFollow: { _ in }
    )
    dependencies.socialUserRepository = SocialUserRepositoryPort(
        fetchUser: { userID in
            userID == authorID ? Domain.User(id: authorID, handle: "author", displayName: "작성자") : nil
        },
        fetchUserByHandle: { _ in nil },
        searchUsers: { _ in [] },
        upsertUser: { _ in }
    )
    dependencies.bragPostRepository = BragPostRepositoryPort(
        fetchFeed: { _, _ in
            [
                Domain.BragPost(
                    id: postID,
                    authorId: authorID,
                    type: .completion,
                    body: "오늘 인증 완료",
                    visibility: .public,
                    comments: await commentStore.all()
                )
            ]
        },
        fetchPosts: { _ in [] },
        createPost: { _ in },
        deletePost: { _ in }
    )
    dependencies.commentRepository = CommentRepositoryPort(
        addComment: { comment in await commentStore.add(comment) },
        fetchComments: { _ in await commentStore.all() },
        deleteComment: { _ in }
    )
    dependencies.notificationScheduler = makeSocialNotificationScheduler(SocialNotificationRecorder())
    let model = FeedModel(dependencies: dependencies)
    let item = FeedPostItem(
        post: Domain.BragPost(
            id: postID,
            authorId: authorID,
            type: .completion,
            body: "오늘 인증 완료",
            visibility: .public
        ),
        author: Domain.User(id: authorID, handle: "author", displayName: "작성자"),
        relation: .stranger,
        taskTitle: nil,
        taskVisibility: nil,
        imageDataItems: [],
        currentUserID: SocialLocalSession.currentUserID
    )
    model.selectedCommentPost = item
    model.commentDraft = "응원합니다"

    model.addComment()

    await waitUntil { await commentStore.count() == 1 }
    await waitUntil { model.selectedCommentPost?.post.comments.count == 1 }
    #expect(model.selectedCommentPost?.post.comments.first?.body == "응원합니다")
    #expect(model.commentDraft.isEmpty)
}

private func makeSocialNotificationScheduler(_ recorder: SocialNotificationRecorder) -> NotificationSchedulerPort {
    NotificationSchedulerPort(
        scheduleDailyReminder: { _, _, _ in },
        cancelReminder: { _ in },
        cancelAllReminders: {},
        requestAuthorization: { true },
        scheduleSocial: { trigger, context in await recorder.record(trigger, context) },
        cancelSocial: { _ in }
    )
}

private func makeSocialRegressionTask(id: TaskID, title: String) -> Domain.Task {
    let start = Calendar.current.startOfDay(for: Date())
    let end = Calendar.current.date(byAdding: .day, value: 2, to: start) ?? start
    return Domain.Task(
        id: id,
        title: title,
        startDate: start,
        endDate: end
    )
}

private func makeSolidRegressionImage() -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 12, height: 12))
    return renderer.image { context in
        UIColor.systemGreen.setFill()
        context.fill(CGRect(x: 0, y: 0, width: 12, height: 12))
    }
}

@MainActor
private func waitUntil(
    timeoutIterations: Int = 50,
    condition: @escaping @MainActor () async -> Bool
) async {
    for _ in 0..<timeoutIterations {
        if await condition() { return }
        try? await _Concurrency.Task.sleep(nanoseconds: 20_000_000)
    }
}
