import Domain

enum SocialVisibilitySupport {
    static func relation(
        viewerID: UserID,
        ownerID: UserID,
        follows: [Follow]
    ) -> ViewerRelation {
        if viewerID == ownerID {
            return .owner
        }

        let pair = follows.filter { follow in
            (follow.fromUserId == viewerID && follow.toUserId == ownerID) ||
                (follow.fromUserId == ownerID && follow.toUserId == viewerID)
        }

        if pair.contains(where: { $0.state == .blocked }) {
            return .blocked
        }

        let accepted = pair.filter { $0.state == .accepted }
        guard !accepted.isEmpty else {
            return .stranger
        }

        let hasForward = accepted.contains { $0.fromUserId == viewerID && $0.toUserId == ownerID }
        let hasReverse = accepted.contains { $0.fromUserId == ownerID && $0.toUserId == viewerID }
        return hasForward && hasReverse || accepted.contains(where: \.isMutual) ? .mutual : .oneWay
    }

    static func visibilityBadge(for visibility: TaskVisibility) -> (title: String, icon: String) {
        switch visibility {
        case .private:
            return ("나만", "lock.fill")
        case .followers:
            return ("친구", "person.2.fill")
        case .public:
            return ("공개", "globe")
        }
    }
}
