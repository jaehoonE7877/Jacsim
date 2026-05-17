import Domain
import Foundation

func mapToDomainModel(_ user: UserModel) -> Domain.User {
    Domain.User(
        id: UserID(user.id),
        handle: user.handle,
        displayName: user.displayName,
        bio: user.bio,
        avatarPath: user.avatarPath,
        createdAt: user.createdAt
    )
}

func mapToSwiftDataModel(_ user: Domain.User, existing: UserModel? = nil) -> UserModel {
    let model = existing ?? UserModel(
        id: user.id.rawValue,
        handle: user.handle,
        displayName: user.displayName
    )
    model.id = user.id.rawValue
    model.handle = user.handle
    model.displayName = user.displayName
    model.bio = user.bio
    model.avatarPath = user.avatarPath
    model.createdAt = user.createdAt
    return model
}

func mapToDomainModel(_ follow: FollowModel, allFollows: [FollowModel]) -> Domain.Follow {
    Domain.Follow(
        id: FollowID(follow.id),
        fromUserId: UserID(follow.fromUserId),
        toUserId: UserID(follow.toUserId),
        state: FollowState(rawValue: follow.stateRaw) ?? .pending,
        requestedAt: follow.requestedAt,
        respondedAt: follow.respondedAt,
        isMutual: follow.isMutual(in: allFollows)
    )
}

func mapToSwiftDataModel(_ follow: Domain.Follow, existing: FollowModel? = nil) -> FollowModel {
    let model = existing ?? FollowModel(
        id: follow.id.rawValue,
        fromUserId: follow.fromUserId.rawValue,
        toUserId: follow.toUserId.rawValue,
        stateRaw: follow.state.rawValue
    )
    model.id = follow.id.rawValue
    model.fromUserId = follow.fromUserId.rawValue
    model.toUserId = follow.toUserId.rawValue
    model.stateRaw = follow.state.rawValue
    model.requestedAt = follow.requestedAt
    model.respondedAt = follow.respondedAt
    return model
}

func mapToDomainModel(
    _ post: BragPostModel,
    cheers: [CheerModel],
    comments: [CommentModel]
) -> Domain.BragPost {
    Domain.BragPost(
        id: BragPostID(post.id),
        authorId: UserID(post.authorId),
        taskId: post.taskId.map(TaskID.init),
        type: BragType(rawValue: post.typeRaw) ?? .completion,
        body: post.body,
        recordImagePaths: post.recordImagePaths,
        createdAt: post.createdAt,
        cheers: cheers
            .filter { $0.postId == post.id }
            .map(mapToDomainModel(_:))
            .sorted { $0.createdAt < $1.createdAt },
        comments: comments
            .filter { $0.postId == post.id }
            .map(mapToDomainModel(_:))
            .sorted { $0.createdAt < $1.createdAt }
    )
}

func mapToSwiftDataModel(_ post: Domain.BragPost, existing: BragPostModel? = nil) -> BragPostModel {
    let model = existing ?? BragPostModel(
        id: post.id.rawValue,
        authorId: post.authorId.rawValue,
        taskId: post.taskId?.rawValue,
        typeRaw: post.type.rawValue,
        body: post.body
    )
    model.id = post.id.rawValue
    model.authorId = post.authorId.rawValue
    model.taskId = post.taskId?.rawValue
    model.typeRaw = post.type.rawValue
    model.body = post.body
    model.recordImagePaths = Array(post.recordImagePaths.prefix(4))
    model.createdAt = post.createdAt
    return model
}

func mapToDomainModel(_ cheer: CheerModel) -> Domain.Cheer {
    Domain.Cheer(
        id: CheerID(cheer.id),
        postId: BragPostID(cheer.postId),
        userId: UserID(cheer.userId),
        createdAt: cheer.createdAt
    )
}

func mapToSwiftDataModel(_ cheer: Domain.Cheer, existing: CheerModel? = nil) -> CheerModel {
    let model = existing ?? CheerModel(
        id: cheer.id.rawValue,
        postId: cheer.postId.rawValue,
        userId: cheer.userId.rawValue
    )
    model.id = cheer.id.rawValue
    model.postId = cheer.postId.rawValue
    model.userId = cheer.userId.rawValue
    model.createdAt = cheer.createdAt
    return model
}

func mapToDomainModel(_ comment: CommentModel) -> Domain.Comment {
    Domain.Comment(
        id: CommentID(comment.id),
        postId: BragPostID(comment.postId),
        authorId: UserID(comment.authorId),
        body: comment.body,
        createdAt: comment.createdAt,
        parentCommentId: comment.parentCommentId.map(CommentID.init)
    )
}

func mapToSwiftDataModel(_ comment: Domain.Comment, existing: CommentModel? = nil) -> CommentModel {
    let model = existing ?? CommentModel(
        id: comment.id.rawValue,
        postId: comment.postId.rawValue,
        authorId: comment.authorId.rawValue,
        body: comment.body
    )
    model.id = comment.id.rawValue
    model.postId = comment.postId.rawValue
    model.authorId = comment.authorId.rawValue
    model.body = comment.body
    model.createdAt = comment.createdAt
    model.parentCommentId = comment.parentCommentId?.rawValue
    return model
}

func mapToDomainModel(_ followChallenge: FollowChallengeModel) -> Domain.FollowChallenge {
    Domain.FollowChallenge(
        id: FollowChallengeID(followChallenge.id),
        originalTaskId: TaskID(followChallenge.originalTaskId),
        copierUserId: UserID(followChallenge.copierUserId),
        copiedTaskId: TaskID(followChallenge.copiedTaskId),
        copiedAt: followChallenge.copiedAt
    )
}

func mapToSwiftDataModel(
    _ followChallenge: Domain.FollowChallenge,
    existing: FollowChallengeModel? = nil
) -> FollowChallengeModel {
    let model = existing ?? FollowChallengeModel(
        id: followChallenge.id.rawValue,
        originalTaskId: followChallenge.originalTaskId.rawValue,
        copierUserId: followChallenge.copierUserId.rawValue,
        copiedTaskId: followChallenge.copiedTaskId.rawValue
    )
    model.id = followChallenge.id.rawValue
    model.originalTaskId = followChallenge.originalTaskId.rawValue
    model.copierUserId = followChallenge.copierUserId.rawValue
    model.copiedTaskId = followChallenge.copiedTaskId.rawValue
    model.copiedAt = followChallenge.copiedAt
    return model
}
