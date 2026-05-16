import Domain
import Foundation
import Observation

public enum FollowButtonState: String, Sendable {
    case follow
    case requested
    case following
    case blocked

    var title: String {
        switch self {
        case .follow:
            return "팔로우"
        case .requested:
            return "요청됨"
        case .following:
            return "팔로잉"
        case .blocked:
            return "차단됨"
        }
    }
}

public struct FriendSearchRow: Identifiable {
    public let user: Domain.User
    public let state: FollowButtonState

    public var id: UUID { user.id.rawValue }
}

@MainActor
@Observable
public final class FriendsSearchModel {
    public var query: String = ""
    public var rows: [FriendSearchRow] = []
    public var isLoading: Bool = false
    public var toastMessage: String?

    @ObservationIgnored public let dependencies: JacsimDependencies
    @ObservationIgnored private var searchTask: _Concurrency.Task<Void, Never>?

    private let currentUserID = SocialLocalSession.currentUserID

    public init(dependencies: JacsimDependencies) {
        self.dependencies = dependencies
    }

    deinit {
        searchTask?.cancel()
    }

    public func queryChanged() {
        searchTask?.cancel()
        let query = query
        isLoading = true
        searchTask = _Concurrency.Task { [dependencies, currentUserID] in
            do {
                let users = try await dependencies.socialUserRepository.searchUsers(query)
                    .filter { $0.id != currentUserID }
                let follows = try await dependencies.followRepository.fetchAll(currentUserID)
                searchResponse(users: users, follows: follows)
            } catch is CancellationError {
                return
            } catch {
                isLoading = false
                rows = []
            }
        }
    }

    public func followTapped(_ row: FriendSearchRow) {
        guard row.state == .follow else { return }
        let follow = Follow(
            id: FollowID(UUID()),
            fromUserId: row.user.id,
            toUserId: currentUserID,
            state: .pending
        )
        _Concurrency.Task { [dependencies] in
            do {
                try await dependencies.followRepository.upsertFollow(follow)
                toastMessage = "요청됨"
                queryChanged()
            } catch {
                toastMessage = "요청하지 못했어요"
            }
        }
    }

    private func searchResponse(users: [Domain.User], follows: [Follow]) {
        rows = users.map { user in
            FriendSearchRow(
                user: user,
                state: state(for: user.id, follows: follows)
            )
        }
        isLoading = false
    }

    private func state(for userID: UserID, follows: [Follow]) -> FollowButtonState {
        let pair = follows.filter {
            ($0.fromUserId == currentUserID && $0.toUserId == userID) ||
                ($0.fromUserId == userID && $0.toUserId == currentUserID)
        }
        if pair.contains(where: { $0.state == .blocked }) {
            return .blocked
        }
        if pair.contains(where: { $0.state == .accepted }) {
            return .following
        }
        if pair.contains(where: { $0.state == .pending }) {
            return .requested
        }
        return .follow
    }
}
