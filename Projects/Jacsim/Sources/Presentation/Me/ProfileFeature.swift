import Domain
import Foundation
import Observation

public enum ProfileSegment: String, CaseIterable, Identifiable {
    case tasks
    case brags

    public var id: String { rawValue }

    var title: String {
        switch self {
        case .tasks:
            return "작심"
        case .brags:
            return "자랑"
        }
    }
}

@MainActor
@Observable
public final class MeModel {
    public let profile: ProfileModel

    public init(dependencies: JacsimDependencies) {
        self.profile = ProfileModel(userID: SocialLocalSession.currentUserID, dependencies: dependencies)
    }
}

@MainActor
@Observable
public final class ProfileModel {
    public var user: Domain.User?
    public var segment: ProfileSegment = .tasks
    public var relation: ViewerRelation = .owner
    public var followerCount: Int = 0
    public var followingCount: Int = 0
    public var tasks: [Domain.Task] = []
    public var posts: [FeedPostItem] = []
    public var isLoading: Bool = false
    public var toastMessage: String?
    public var follows: [Follow] = []

    @ObservationIgnored public let userID: UserID
    @ObservationIgnored public let dependencies: JacsimDependencies
    @ObservationIgnored private var loadTask: _Concurrency.Task<Void, Never>?

    private let currentUserID = SocialLocalSession.currentUserID

    public init(userID: UserID, dependencies: JacsimDependencies) {
        self.userID = userID
        self.dependencies = dependencies
    }

    deinit {
        loadTask?.cancel()
    }

    public var isOwnProfile: Bool {
        userID == currentUserID
    }

    public var canViewTaskList: Bool {
        canView(.taskList, relation: relation, taskVisibility: isOwnProfile ? .private : .followers)
    }

    public func onAppear() {
        load()
    }

    public func load() {
        isLoading = true
        loadTask?.cancel()
        loadTask = _Concurrency.Task { [dependencies, userID, currentUserID] in
            do {
                let allFollows = try await dependencies.followRepository.fetchAll(currentUserID)
                let relation = SocialVisibilitySupport.relation(
                    viewerID: currentUserID,
                    ownerID: userID,
                    follows: allFollows
                )
                let user = try await dependencies.socialUserRepository.fetchUser(userID) ?? fallbackUser(for: userID)
                let tasks: [Domain.Task]
                if userID == currentUserID {
                    let active = try await dependencies.taskQueryClient.fetchActiveTasks()
                    let done = try await dependencies.taskQueryClient.fetchTasksByStatus(.done)
                    tasks = active + done
                } else {
                    tasks = []
                }
                let rawPosts = try await dependencies.bragPostRepository.fetchPosts(userID)
                let posts = rawPosts
                    .filter { _ in canView(.bragPost, relation: relation, taskVisibility: nil) }
                    .map {
                        FeedPostItem(
                            post: $0,
                            author: user,
                            relation: relation,
                            taskTitle: nil,
                            taskVisibility: nil,
                            currentUserID: currentUserID
                        )
                    }

                profileResponse(
                    user: user,
                    relation: relation,
                    follows: allFollows,
                    tasks: tasks,
                    posts: posts
                )
            } catch {
                profileFailed()
            }
        }
    }

    public func blockTapped() {
        upsertRelation(state: .blocked)
    }

    public func unfollowTapped() {
        upsertRelation(state: .rejected)
    }

    private func upsertRelation(state: FollowState) {
        let existing = firstPairFollow()
        let follow = Follow(
            id: existing?.id ?? FollowID(UUID()),
            fromUserId: currentUserID,
            toUserId: userID,
            state: state,
            requestedAt: existing?.requestedAt ?? .now,
            respondedAt: .now
        )
        _Concurrency.Task { [dependencies] in
            do {
                try await dependencies.followRepository.upsertFollow(follow)
                load()
            } catch {
                toastMessage = "관계를 변경하지 못했어요"
            }
        }
    }

    private func firstPairFollow() -> Follow? {
        follows.first {
            ($0.fromUserId == currentUserID && $0.toUserId == userID) ||
                ($0.fromUserId == userID && $0.toUserId == currentUserID)
        }
    }

    private func profileResponse(
        user: Domain.User,
        relation: ViewerRelation,
        follows: [Follow],
        tasks: [Domain.Task],
        posts: [FeedPostItem]
    ) {
        self.user = user
        self.relation = relation
        self.followerCount = follows.filter { $0.state == .accepted && $0.toUserId == userID }.count
        self.followingCount = follows.filter { $0.state == .accepted && $0.fromUserId == userID }.count
        self.follows = follows
        self.tasks = tasks
        self.posts = posts
        self.isLoading = false
    }

    private func profileFailed() {
        isLoading = false
        toastMessage = "프로필을 불러오지 못했어요"
    }

    private nonisolated func fallbackUser(for userID: UserID) -> Domain.User {
        Domain.User(id: userID, handle: "local", displayName: "작심러")
    }
}
